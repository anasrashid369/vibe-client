import '../../data/datasources/drift_embedding_local_data_source.dart';
import '../../data/datasources/embedding_remote_data_source.dart';

/// Best-effort embedding + caching for vibe search. Failures here must
/// never block onboarding or discovery -- vibe search is an
/// enhancement, not a core-path dependency.
class EmbedAndCacheMovies {
  EmbedAndCacheMovies(this._remote, this._local);

  final EmbeddingRemoteDataSource _remote;
  final DriftEmbeddingLocalDataSource _local;

  Future<void> call(Map<int, String> textsByMovieId) async {
    if (textsByMovieId.isEmpty) return;

    try {
      final ids = textsByMovieId.keys.toList();
      final texts = ids.map((id) => textsByMovieId[id]!).toList();
      final vectors = await _remote.embedTexts(texts);

      final map = <int, List<double>>{};
      for (var i = 0; i < ids.length && i < vectors.length; i++) {
        map[ids[i]] = vectors[i];
      }
      await _local.saveEmbeddings(map);
    } catch (_) {
      // Swallow -- see class doc. Vibe search will just have less to
      // search over; the user's actual task (onboarding/discovery)
      // must never fail because of this.
    }
  }
}
