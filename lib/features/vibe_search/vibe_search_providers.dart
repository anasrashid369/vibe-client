import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dependencies.dart';
import '../taste/taste_providers.dart';
import 'data/datasources/drift_embedding_local_data_source.dart';
import 'data/datasources/embedding_remote_data_source.dart';
import 'domain/usecases/embed_and_cache_movies.dart';
import 'domain/usecases/semantic_search.dart';

final embeddingRemoteDataSourceProvider = Provider<EmbeddingRemoteDataSource>((ref) {
  return EmbeddingRemoteDataSource(ref.watch(dioClientProvider).dio);
});

final embeddingLocalDataSourceProvider = Provider<DriftEmbeddingLocalDataSource>((ref) {
  return DriftEmbeddingLocalDataSource(ref.watch(databaseProvider));
});

final embedAndCacheMoviesProvider = Provider<EmbedAndCacheMovies>((ref) {
  return EmbedAndCacheMovies(
    ref.watch(embeddingRemoteDataSourceProvider),
    ref.watch(embeddingLocalDataSourceProvider),
  );
});

final semanticSearchProvider = Provider<SemanticSearch>((ref) {
  return SemanticSearch(
    ref.watch(embeddingRemoteDataSourceProvider),
    ref.watch(embeddingLocalDataSourceProvider),
    ref.watch(tasteLocalDataSourceProvider),
  );
});
