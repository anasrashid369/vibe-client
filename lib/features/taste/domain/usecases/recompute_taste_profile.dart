import '../../data/datasources/drift_taste_local_data_source.dart';
import '../entities/interaction.dart';
import '../entities/taste_profile.dart';

/// Local heuristic recompute -- no API call needed for this step (spec
/// §3.2). Now genre-aware: joins liked interactions against the local
/// movies_cache (populated whenever discovery/onboarding fetches movies)
/// to find which genres actually show up in what the user likes.
class RecomputeTasteProfile {
  RecomputeTasteProfile(this._dataSource);

  final DriftTasteLocalDataSource _dataSource;

  Future<TasteProfileEntity> call() async {
    final interactions = await _dataSource.getRecentInteractions();
    final count = interactions.length;

    final liked = interactions.where((i) => i.action == InteractionAction.liked).toList();
    final skipped = interactions.where((i) => i.action == InteractionAction.skipped).length;

    final likedIds = liked.map((i) => i.movieId).toSet();
    final genresByMovie = await _dataSource.getGenresForMovies(likedIds);

    final genreCounts = <String, int>{};
    for (final movieId in likedIds) {
      for (final genre in genresByMovie[movieId] ?? const <String>[]) {
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }

    final topGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGenreNames = topGenres.take(5).map((e) => e.key).toList();

    final summary = count == 0
        ? 'No preferences recorded yet.'
        : topGenreNames.isEmpty
            ? 'Has liked ${liked.length} and skipped $skipped movies out of $count recent interactions.'
            : 'Prefers ${topGenreNames.join(", ")}. Has liked ${liked.length} and skipped $skipped movies out of $count recent interactions.';

    final profile = TasteProfileEntity(
      summaryText: summary,
      topGenres: topGenreNames,
      topPeople: const [], // TODO(Phase 2): derive from cast data once available
      moodTags: const [],
      interactionCountAtUpdate: count,
      updatedAt: DateTime.now(),
    );

    await _dataSource.saveTasteProfile(profile);
    return profile;
  }
}