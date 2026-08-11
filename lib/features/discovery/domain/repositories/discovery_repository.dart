import '../../../../core/network/result.dart';
import '../entities/movie.dart';
import '../entities/recommendation_result.dart';

abstract class DiscoveryRepository {
  Future<Result<RecommendationResult>> getRecommendations({
    required String tasteProfileSummary,
    required List<String> topGenres,
    required List<int> recentLikes,
    required List<int> excludeIds,
  });

  Future<Result<List<Movie>>> getCandidates({String? genre});
}