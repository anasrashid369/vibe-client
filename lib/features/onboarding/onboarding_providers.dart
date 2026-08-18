import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../discovery/discovery_providers.dart';
import '../discovery/domain/entities/movie.dart';
import '../taste/taste_providers.dart';
import '../vibe_search/vibe_search_providers.dart';
import 'domain/usecases/seed_initial_taste.dart';

final onboardingCandidatesProvider = FutureProvider.autoDispose<List<Movie>>((ref) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  final result = await repo.getCandidates();
  final movies = result.when(ok: (movies) => movies, err: (error) => throw error);

  // Cache so RecomputeTasteProfile can later look up genres for
  // whatever the user picks here.
  await ref.read(tasteLocalDataSourceProvider).cacheMovies(
        movies
            .map((m) => (id: m.id, title: m.title, genres: m.genres, posterPath: m.posterPath))
            .toList(),
      );

  // Best-effort: embed these movies' overviews so vibe search has
  // something to search over. Never blocks onboarding if it fails.
  await ref.read(embedAndCacheMoviesProvider).call({
    for (final m in movies) m.id: m.overview.isNotEmpty ? m.overview : m.title,
  });

  return movies;
});

final seedInitialTasteProvider = Provider<SeedInitialTaste>((ref) {
  return SeedInitialTaste(ref.watch(recordInteractionProvider));
});
