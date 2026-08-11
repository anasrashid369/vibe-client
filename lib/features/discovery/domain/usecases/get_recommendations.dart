import '../../../../core/network/result.dart';
import '../entities/recommendation_result.dart';
import '../repositories/discovery_repository.dart';

class GetRecommendations {
  GetRecommendations(this._repository);

  final DiscoveryRepository _repository;

  Future<Result<RecommendationResult>> call({
    required String tasteProfileSummary,
    required List<String> topGenres,
    required List<int> recentLikes,
    required List<int> excludeIds,
  }) {
    return _repository.getRecommendations(
      tasteProfileSummary: tasteProfileSummary,
      topGenres: topGenres,
      recentLikes: recentLikes,
      excludeIds: excludeIds,
    );
  }
}