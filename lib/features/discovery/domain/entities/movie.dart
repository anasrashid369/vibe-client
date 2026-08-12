class Movie {
  const Movie({required this.id, required this.title, required this.overview, this.posterPath});

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
}