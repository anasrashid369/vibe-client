import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/result.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/recommendation_result.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasources/bff_remote_data_source.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  DiscoveryRepositoryImpl(this._remote);

  final BffRemoteDataSource _remote;

  @override
  Future<Result<RecommendationResult>> getRecommendations({
    required String tasteProfileSummary,
    required List<String> topGenres,
    required List<int> recentLikes,
    required List<int> excludeIds,
  }) async {
    try {
      final model = await _remote.getRecommendations(
        tasteProfileSummary: tasteProfileSummary,
        topGenres: topGenres,
        recentLikes: recentLikes,
        excludeIds: excludeIds,
      );

      final result = RecommendationResult(
        source: model.source == 'ai' ? RecommendationSource.ai : RecommendationSource.fallback,
        providerUsed: model.providerUsed,
        recommendations: model.recommendations
            .map((r) => Recommendation(
                  movieId: r.movieId,
                  title: r.title,
                  reason: r.reason,
                  confidence: r.confidence,
                ))
            .toList(),
        fallbackTriggered: model.fallbackTriggered,
      );

      return Result.ok(result);
    } on DioException catch (e) {
      return Result.err(_mapDioError(e));
    } catch (e) {
      return Result.err(ParsingException(e.toString()));
    }
  }

  @override
  Future<Result<List<Movie>>> getCandidates({String? genre}) async {
    try {
      final models = await _remote.getCandidates(genre: genre);
      final movies = models.map((m) => Movie(id: m.id, title: m.title, overview: m.overview)).toList();
      return Result.ok(movies);
    } on DioException catch (e) {
      return Result.err(_mapDioError(e));
    } catch (e) {
      return Result.err(ParsingException(e.toString()));
    }
  }

  /// Maps every raw Dio/HTTP failure onto our own AppException hierarchy
  /// so the UI never has to know what "DioExceptionType.badResponse"
  /// means — just NetworkException, TimeoutException, etc.
  AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) return const AuthException();
        if (status != null && status >= 500) return const ServerException();
        return const ValidationException();
      default:
        return const ServerException();
    }
  }
}