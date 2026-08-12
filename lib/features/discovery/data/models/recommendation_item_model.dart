import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation_item_model.freezed.dart';
part 'recommendation_item_model.g.dart';

@freezed
class RecommendationItemModel with _$RecommendationItemModel {
  const factory RecommendationItemModel({
    @JsonKey(name: 'movie_id') required int movieId,
    required String title,
    required String reason,
    required String confidence,
    @JsonKey(name: 'poster_path') String? posterPath,
  }) = _RecommendationItemModel;

  factory RecommendationItemModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendationItemModelFromJson(json);
}