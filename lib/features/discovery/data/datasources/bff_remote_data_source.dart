import 'package:dio/dio.dart';

import '../models/candidate_movie_model.dart';
import '../models/recommendation_response_model.dart';

/// The only place in the client that knows the BFF's URL shapes. Never
/// calls TMDB or an LLM directly — everything goes through the BFF
/// (spec §3.1).
class BffRemoteDataSource {
  BffRemoteDataSource(this._dio);

  final Dio _dio;

  Future<RecommendationResponseModel> getRecommendations({
    required String tasteProfileSummary,
    required List<String> topGenres,
    required List<int> recentLikes,
    required List<int> excludeIds,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/recommendations',
      data: {
        'taste_profile_summary': tasteProfileSummary,
        'top_genres': topGenres,
        'recent_likes': recentLikes,
        'exclude_ids': excludeIds,
      },
    );
    return RecommendationResponseModel.fromJson(response.data!);
  }

  Future<List<CandidateMovieModel>> getCandidates({String? genre}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/movies/candidates',
      queryParameters: {if (genre != null) 'genre': genre},
    );
    final list = response.data!['candidates'] as List;
    return list.map((e) => CandidateMovieModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}