import '../../data/datasources/drift_taste_local_data_source.dart';
import '../entities/interaction.dart';
import '../entities/taste_profile.dart';

/// Local heuristic recompute — no API call needed for this step (spec
/// §3.2). Produces a short natural-language summary that gets sent to
/// the BFF as context on every recommendation request.
///
/// NOTE: interactions only store movie_id, not genre/actor data — a
/// fuller implementation joins against movies_cache to derive real
/// top_genres. Kept simple for MVP: summarizes interaction counts by
/// action type. TODO(Phase 1 follow-up): join movies_cache once the
/// discovery feature populates it.
class RecomputeTasteProfile {
  RecomputeTasteProfile(this._dataSource);

  final DriftTasteLocalDataSource _dataSource;

  Future<TasteProfileEntity> call() async {
    final interactions = await _dataSource.getRecentInteractions();
    final count = interactions.length;

    final liked = interactions.where((i) => i.action == InteractionAction.liked).length;
    final skipped = interactions.where((i) => i.action == InteractionAction.skipped).length;

    final summary = count == 0
        ? 'No preferences recorded yet.'
        : 'Has liked $liked and skipped $skipped movies out of $count recent interactions.';

    final profile = TasteProfileEntity(
      summaryText: summary,
      topGenres: const [], // TODO(Phase 1 follow-up): derive from movies_cache join
      topPeople: const [],
      moodTags: const [],
      interactionCountAtUpdate: count,
      updatedAt: DateTime.now(),
    );

    await _dataSource.saveTasteProfile(profile);
    return profile;
  }
}