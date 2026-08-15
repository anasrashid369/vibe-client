class Recommendation {
  const Recommendation({
    required this.movieId,
    required this.title,
    required this.reason,
    required this.confidence,
    this.posterPath,
    this.genres = const [],
  });

  final int movieId;
  final String title;
  final String reason;
  final String confidence; // 'high' | 'medium' | 'low'
  final String? posterPath;
  final List<String> genres;
}