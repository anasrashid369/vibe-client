import 'recommendation.dart';

enum RecommendationSource { ai, fallback }

class RecommendationResult {
  const RecommendationResult({
    required this.source,
    required this.providerUsed,
    required this.recommendations,
    required this.fallbackTriggered,
  });

  final RecommendationSource source;
  final String? providerUsed;
  final List<Recommendation> recommendations;
  final bool fallbackTriggered;
}