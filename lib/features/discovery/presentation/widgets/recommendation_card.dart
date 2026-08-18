import 'package:flutter/material.dart';

import '../../domain/entities/recommendation.dart';
import 'typewriter_text.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onLike,
    required this.onSkip,
  });

  final Recommendation recommendation;
  final VoidCallback onLike;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            height: 135,
            child: recommendation.posterPath != null
                ? Image.network(
                    'https://image.tmdb.org/t/p/w342${recommendation.posterPath}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _posterFallback(),
                  )
                : _posterFallback(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recommendation.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  // Screen readers get the full reason immediately
                  // (excludeSemantics + explicit label) rather than
                  // waiting for the character-by-character reveal,
                  // which is a purely visual effect for sighted users.
                  Semantics(
                    label: recommendation.reason,
                    child: ExcludeSemantics(
                      child: TypewriterText(
                        text: recommendation.reason,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onSkip,
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Skip'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onLike,
                          icon: const Icon(Icons.favorite_border, size: 16),
                          label: const Text('Like'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _posterFallback() {
    return Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.movie, color: Colors.grey),
    );
  }
}