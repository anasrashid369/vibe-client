import 'package:freezed_annotation/freezed_annotation.dart';

part 'candidate_movie_model.freezed.dart';
part 'candidate_movie_model.g.dart';

@freezed
class CandidateMovieModel with _$CandidateMovieModel {
  const factory CandidateMovieModel({
    required int id,
    required String title,
    required String overview,
  }) = _CandidateMovieModel;

  factory CandidateMovieModel.fromJson(Map<String, dynamic> json) =>
      _$CandidateMovieModelFromJson(json);
}