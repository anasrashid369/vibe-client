import 'dart:typed_data';

import 'package:drift/drift.dart';

import '../../../../core/storage/database.dart';

/// Stores embedding vectors as raw bytes (Float32 encoding) in the
/// movie_embeddings table -- this is the local vector index the spec's
/// vibe-search feature searches over, entirely on-device.
class DriftEmbeddingLocalDataSource {
  DriftEmbeddingLocalDataSource(this._db);

  final AppDatabase _db;

  static const modelVersion = 'gemini-embedding-001';

  Future<void> saveEmbeddings(Map<int, List<double>> embeddingsByMovieId) async {
    if (embeddingsByMovieId.isEmpty) return;

    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.movieEmbeddings,
        embeddingsByMovieId.entries
            .map((e) => MovieEmbeddingsCompanion.insert(
                  movieId: Value(e.key),
                  vector: _encode(e.value),
                  modelVersion: modelVersion,
                ))
            .toList(),
      );
    });
  }

  Future<List<({int movieId, List<double> vector})>> getAllEmbeddings() async {
    final rows = await _db.select(_db.movieEmbeddings).get();
    return rows.map((r) => (movieId: r.movieId, vector: _decode(r.vector))).toList();
  }

  Uint8List _encode(List<double> vector) {
    final floatList = Float32List.fromList(vector);
    return floatList.buffer.asUint8List();
  }

  List<double> _decode(Uint8List bytes) {
    final floatList = Float32List.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes ~/ 4);
    return floatList.toList();
  }
}
