enum InteractionAction { liked, skipped, watched, rated }

class Interaction {
  const Interaction({
    required this.movieId,
    required this.action,
    this.rating,
    required this.createdAt,
  });

  final int movieId;
  final InteractionAction action;
  final double? rating;
  final DateTime createdAt;
}