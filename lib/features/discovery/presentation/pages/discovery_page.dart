import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../taste/domain/entities/interaction.dart';
import '../../../taste/taste_providers.dart';
import '../../domain/entities/recommendation_result.dart';
import '../controllers/discovery_controller.dart';
import '../widgets/ai_source_badge.dart';
import '../widgets/recommendation_card.dart';

class DiscoveryPage extends ConsumerWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('For You')),
      // Explicit loading / error / empty / data states — no infinite
      // spinners, no silent failures (spec §7.1 item 6).
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error is AppException ? error.message : 'Something went wrong.',
          onRetry: () => ref.read(discoveryControllerProvider.notifier).refresh(),
        ),
        data: (result) {
          if (result.recommendations.isEmpty) return const _EmptyState();

          return RefreshIndicator(
            onRefresh: () => ref.read(discoveryControllerProvider.notifier).refresh(),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AiSourceBadge(isAi: result.source == RecommendationSource.ai),
                  ),
                ),
                ...result.recommendations.map(
                  (rec) => RecommendationCard(
                    recommendation: rec,
                    onLike: () => _record(ref, rec.movieId, InteractionAction.liked),
                    onSkip: () => _record(ref, rec.movieId, InteractionAction.skipped),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _record(WidgetRef ref, int movieId, InteractionAction action) async {
    await ref.read(recordInteractionProvider).call(
          Interaction(movieId: movieId, action: action, createdAt: DateTime.now()),
        );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No recommendations yet — try rating a few movies first.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}