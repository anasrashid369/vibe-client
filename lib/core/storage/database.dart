import 'package:drift/drift.dart';

// TODO: `part 'database.g.dart';` once build_runner codegen is wired up.

/// movies_cache — cached TMDB metadata.
class MoviesCache extends Table {
  IntColumn get id => integer()(); // TMDB id
  TextColumn get title => text()();
  TextColumn get overview => text()();
  TextColumn get genres => text()(); // JSON-encoded list
  TextColumn get posterPath => text().nullable()();
  TextColumn get releaseDate => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// interactions — every like/skip/watch/rate event, written immediately.
class Interactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get movieId => integer()();
  TextColumn get action => text()(); // 'liked' | 'skipped' | 'watched' | 'rated'
  RealColumn get rating => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// taste_profile — singleton row (id = 1), the summary fed to the LLM.
class TasteProfile extends Table {
  IntColumn get id => integer()(); // always 1
  TextColumn get summaryText => text()();
  TextColumn get topGenres => text()(); // JSON
  TextColumn get topPeople => text()(); // JSON
  TextColumn get moodTags => text()(); // JSON
  IntColumn get interactionCountAtUpdate => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// movie_embeddings — local vectors for vibe/semantic search (Phase 2).
class MovieEmbeddings extends Table {
  IntColumn get movieId => integer()();
  BlobColumn get vector => blob()(); // serialized float32 array
  TextColumn get modelVersion => text()();

  @override
  Set<Column> get primaryKey => {movieId};
}

// TODO:
// @DriftDatabase(tables: [MoviesCache, Interactions, TasteProfile, MovieEmbeddings])
// class AppDatabase extends _$AppDatabase { ... }
