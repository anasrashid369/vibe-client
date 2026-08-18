import 'package:dio/dio.dart';

/// Calls the BFF's embedding endpoints. Never talks to the embedding
/// model directly -- same grounding/secrets principle as the rest of
/// the app (spec §3.1).
class EmbeddingRemoteDataSource {
  EmbeddingRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<List<double>>> embedTexts(List<String> texts) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/embed',
      data: {'texts': texts},
    );
    final raw = response.data!['embeddings'] as List;
    return raw
        .map((e) => List<double>.from((e as List).map((v) => (v as num).toDouble())))
        .toList();
  }

  Future<List<double>> embedQuery(String queryText) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/search/vibe',
      data: {'query_text': queryText},
    );
    final raw = response.data!['embedding'] as List;
    return List<double>.from(raw.map((v) => (v as num).toDouble()));
  }
}
