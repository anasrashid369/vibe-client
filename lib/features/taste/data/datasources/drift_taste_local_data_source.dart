import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/storage/database.dart';
import '../../domain/entities/interaction.dart';
import '../../domain/entities/taste_profile.dart';

/// Talks directly to Drift. This is the only place in the app that
/// knows about the database's table/column shapes -- everything above
/// this layer works with domain entities instead.
class DriftTasteLocalDataSource {
  DriftTasteLocalDataSource(this._db);

  final AppDatabase _db;

  Future<void> recordInteraction(Interaction interaction) async {
    await _db.into(_db.interactions).insert(
          InteractionsCompanion.insert(
            movieId: interaction.movieId,
            action: interaction.action.name,
            rating: Value(interaction.rating),
            createdAt: interaction.createdAt,
          ),
        );
  }

  Future<int> countInteractions() async {
    final countExp = _db.interactions.id.count();
    final query = _db.selectOnly(_db.interactions)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<TasteProfileEntity?> getTasteProfile() async {
    final row =
        await (_db.select(_db.tasteProfile)..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row == null) return null;

    return TasteProfileEntity(
      summaryText: row.summaryText,
      topGenres: List<String>.from(jsonDecode(row.topGenres) as List),
      topPeople: List<String>.from(jsonDecode(row.topPeople) as List),
      moodTags: List<String>.from(jsonDecode(row.moodTags) as List),
      interactionCountAtUpdate: row.interactionCountAtUpdate,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> saveTasteProfile(TasteProfileEntity profile) async {
    await _db.into(_db.tasteProfile).insertOnConflictUpdate(
          TasteProfileCompanion.insert(
            id: const Value(1),
            summaryText: profile.summaryText,
            topGenres: jsonEncode(profile.topGenres),
            topPeople: jsonEncode(profile.topPeople),
            moodTags: jsonEncode(profile.moodTags),
            interactionCountAtUpdate: profile.interactionCountAtUpdate,
            updatedAt: profile.updatedAt,
          ),
        );
  }

  Future<List<Interaction>> getRecentInteractions({int limit = 200}) async {
    final rows = await (_db.select(_db.interactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();

    return rows
        .map((r) => Interaction(
              movieId: r.movieId,
              action: InteractionAction.values.byName(r.action),
              rating: r.rating,
              createdAt: r.createdAt,
            ))
        .toList();
  }

  /// Caches basic movie metadata (title, genres, poster) locally so we
  /// can later join interactions against it to derive real genre-based
  /// taste, without needing a network round-trip per lookup. Called
  /// whenever discovery or onboarding fetches movies from the BFF.
  Future<void> cacheMovies(List<({int id, String title, List<String> genres, String? posterPath})> movies) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.moviesCache,
        movies
            .map((m) => MoviesCacheCompanion.insert(
                  id: Value(m.id),
                  title: m.title,
                  overview: '',
                  genres: jsonEncode(m.genres),
                  posterPath: Value(m.posterPath),
                  cachedAt: DateTime.now(),
                ))
            .toList(),
      );
    });
  }

  /// Looks up cached genres for a set of movie IDs -- used by
  /// RecomputeTasteProfile to turn "liked movie 155" into "liked a
  /// Crime/Thriller movie".
  Future<Map<int, List<String>>> getGenresForMovies(Set<int> movieIds) async {
    if (movieIds.isEmpty) return {};

    final rows =
        await (_db.select(_db.moviesCache)..where((t) => t.id.isIn(movieIds))).get();

    return {
      for (final row in rows) row.id: List<String>.from(jsonDecode(row.genres) as List),
    };
  }

  /// Looks up full display details (title, poster, genres) for a set of
  /// movie IDs -- used by vibe search to render results.
  Future<Map<int, ({String title, String? posterPath, List<String> genres})>> getCachedMovieDetails(
    Set<int> movieIds,
  ) async {
    if (movieIds.isEmpty) return {};

    final rows =
        await (_db.select(_db.moviesCache)..where((t) => t.id.isIn(movieIds))).get();

    return {
      for (final row in rows)
        row.id: (
          title: row.title,
          posterPath: row.posterPath,
          genres: List<String>.from(jsonDecode(row.genres) as List),
        ),
    };
  }
}
