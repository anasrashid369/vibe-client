import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

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
/// DataClassName override avoids a collision: Drift's default naming
/// would generate a class called `Interaction`, which clashes with our
/// own domain entity of the same name (features/taste/domain/entities).
@DataClassName('InteractionRow')
class Interactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get movieId => integer()();
  TextColumn get action => text()();
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

@DriftDatabase(tables: [MoviesCache, Interactions, TasteProfile, MovieEmbeddings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  // Lazily opens the sqlite file on first use, in the app's documents
  // directory — not committed, not synced, purely local (spec: MVP is
  // single-device, local-first only).
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vibe.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}