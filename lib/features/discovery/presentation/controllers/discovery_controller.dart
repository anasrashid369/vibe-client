import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../taste/domain/entities/interaction.dart';
import '../../../taste/taste_providers.dart';
import '../../../vibe_search/vibe_search_providers.dart';
import '../../discovery_providers.dart';
import '../../domain/entities/recommendation_result.dart';

/// AsyncNotifier maps cleanly onto "request in flight / succeeded / fell
/// back / failed" -- exactly the state shape the spec calls for.
class DiscoveryController extends AsyncNotifier<RecommendationResult> {
  @override
  Future<RecommendationResult> build() => _fetch();

  Future<RecommendationResult> _fetch() async {
    final tasteDataSource = ref.read(tasteLocalDataSourceProvider);
    final profile = await tasteDataSource.getTasteProfile();

    // Real recentLikes/excludeIds now, instead of hardcoded empty lists
    // -- this is what makes rating movies actually change what the BFF
    // sees on the next request (spec §7.3 acceptance criteria).
    final recentInteractions = await tasteDataSource.getRecentInteractions(limit: 50);
    final recentLikes = recentInteractions
        .where((i) => i.action == InteractionAction.liked)
        .map((i) => i.movieId)
        .toList();
    final excludeIds = recentInteractions.map((i) => i.movieId).toSet().toList();

    final result = await ref.read(getRecommendationsProvider).call(
          tasteProfileSummary: profile?.summaryText ?? 'No preferences recorded yet.',
          topGenres: profile?.topGenres ?? const [],
          recentLikes: recentLikes,
          excludeIds: excludeIds,
        );

    final recommendationResult = result.when(ok: (data) => data, err: (error) => throw error);

    // Cache for genre-derivation.
    await tasteDataSource.cacheMovies(
      recommendationResult.recommendations
          .map((r) => (id: r.movieId, title: r.title, genres: r.genres, posterPath: r.posterPath))
          .toList(),
    );

    // Best-effort: embed these too, so vibe search's index grows from
    // discovery browsing, not just onboarding. Recommendations don't
    // carry a full overview, so we build a descriptive proxy text from
    // what we do have.
    await ref.read(embedAndCacheMoviesProvider).call({
      for (final r in recommendationResult.recommendations)
        r.movieId: '${r.title}. ${r.genres.join(", ")}. ${r.reason}',
    });

    return recommendationResult;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final discoveryControllerProvider =
    AsyncNotifierProvider<DiscoveryController, RecommendationResult>(DiscoveryController.new);
