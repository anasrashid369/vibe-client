import 'package:freezed_annotation/freezed_annotation.dart';

import 'recommendation_item_model.dart';

part 'recommendation_response_model.freezed.dart';
part 'recommendation_response_model.g.dart';

@freezed
class RecommendationResponseModel with _$RecommendationResponseModel {
  const factory RecommendationResponseModel({
    required String source, // 'ai' | 'fallback'
    @JsonKey(name: 'provider_used') String? providerUsed,
    required List<RecommendationItemModel> recommendations,
    @JsonKey(name: 'fallback_triggered') required bool fallbackTriggered,
    @JsonKey(name: 'generated_at') required String generatedAt,
  }) = _RecommendationResponseModel;

  factory RecommendationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendationResponseModelFromJson(json);
}