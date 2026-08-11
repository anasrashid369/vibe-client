import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../taste/taste_providers.dart';
import '../../discovery_providers.dart';
import '../../domain/entities/recommendation_result.dart';

/// AsyncNotifier maps cleanly onto "request in flight / succeeded / fell
/// back / failed" — exactly the state shape the spec calls for.
class DiscoveryController extends AsyncNotifier<RecommendationResult> {
  @override
  Future<RecommendationResult> build() => _fetch();

  Future<RecommendationResult> _fetch() async {
    final profile = await ref.read(tasteLocalDataSourceProvider).getTasteProfile();

    final result = await ref.read(getRecommendationsProvider).call(
          tasteProfileSummary: profile?.summaryText ?? 'No preferences recorded yet.',
          topGenres: profile?.topGenres ?? const [],
          recentLikes: const [], // TODO(Phase 1 follow-up): populate from recent likes
          excludeIds: const [],
        );

    return result.when(ok: (data) => data, err: (error) => throw error);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final discoveryControllerProvider =
    AsyncNotifierProvider<DiscoveryController, RecommendationResult>(DiscoveryController.new);