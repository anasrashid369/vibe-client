import 'dart:isolate';
import 'dart:math';

import '../../../taste/data/datasources/drift_taste_local_data_source.dart';
import '../../data/datasources/drift_embedding_local_data_source.dart';
import '../../data/datasources/embedding_remote_data_source.dart';

class SemanticSearchResult {
  const SemanticSearchResult({
    required this.movieId,
    required this.title,
    required this.posterPath,
    required this.genres,
    required this.score,
  });

  final int movieId;
  final String title;
  final String? posterPath;
  final List<String> genres;
  final double score;
}

class _ScoredMovieId {
  const _ScoredMovieId(this.movieId, this.score);
  final int movieId;
  final double score;
}

/// Cosine-similarity search across the local embeddings index, run in
/// an isolate per the spec's isolate-usage guidance (§4.3) -- keeps the
/// UI thread free as the local catalog grows, without needing to
/// profile first for the small catalogs an early user will have.
Future<List<_ScoredMovieId>> _searchVectors(
  List<double> queryVector,
  List<({int movieId, List<double> vector})> index,
) {
  return Isolate.run(() {
    final scored = index
        .map((entry) => _ScoredMovieId(entry.movieId, _cosineSimilarity(queryVector, entry.vector)))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scored.take(20).toList();
  });
}

double _cosineSimilarity(List<double> a, List<double> b) {
  if (a.length != b.length || a.isEmpty) return 0;
  double dot = 0, normA = 0, normB = 0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  if (normA == 0 || normB == 0) return 0;
  return dot / (sqrt(normA) * sqrt(normB));
}

/// Full vibe-search flow: embed the query via the BFF (server-side,
/// spec §5.2), then compare against the local vector index entirely
/// on-device.
class SemanticSearch {
  SemanticSearch(this._embeddingRemote, this._embeddingLocal, this._tasteDataSource);

  final EmbeddingRemoteDataSource _embeddingRemote;
  final DriftEmbeddingLocalDataSource _embeddingLocal;
  final DriftTasteLocalDataSource _tasteDataSource;

  Future<List<SemanticSearchResult>> call(String queryText) async {
    final queryVector = await _embeddingRemote.embedQuery(queryText);
    final index = await _embeddingLocal.getAllEmbeddings();

    if (index.isEmpty) return [];

    final scored = await _searchVectors(queryVector, index);
    final details = await _tasteDataSource.getCachedMovieDetails(
      scored.map((s) => s.movieId).toSet(),
    );

    return scored
        .where((s) => details.containsKey(s.movieId))
        .map((s) {
          final d = details[s.movieId]!;
          return SemanticSearchResult(
            movieId: s.movieId,
            title: d.title,
            posterPath: d.posterPath,
            genres: d.genres,
            score: s.score,
          );
        })
        .toList();
  }
}
