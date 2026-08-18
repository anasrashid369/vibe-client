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
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout: single-column list on narrow
                // windows, multi-column grid once there's enough width
                // that a list starts feeling wasteful.
                final isWide = constraints.maxWidth >= 700;

                final badge = Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AiSourceBadge(isAi: result.source == RecommendationSource.ai),
                  ),
                );

                if (!isWide) {
                  return ListView(
                    children: [
                      badge,
                      ...result.recommendations.map(
                        (rec) => RecommendationCard(
                          recommendation: rec,
                          onLike: () => _record(context, ref, rec.movieId, rec.title, InteractionAction.liked),
                          onSkip: () => _record(context, ref, rec.movieId, rec.title, InteractionAction.skipped),
                        ),
                      ),
                    ],
                  );
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: badge),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 420,
                          mainAxisExtent: 180,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final rec = result.recommendations[index];
                            return RecommendationCard(
                              recommendation: rec,
                              onLike: () => _record(context, ref, rec.movieId, rec.title, InteractionAction.liked),
                              onSkip: () => _record(context, ref, rec.movieId, rec.title, InteractionAction.skipped),
                            );
                          },
                          childCount: result.recommendations.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _record(
    BuildContext context,
    WidgetRef ref,
    int movieId,
    String title,
    InteractionAction action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(recordInteractionProvider).call(
            Interaction(movieId: movieId, action: action, createdAt: DateTime.now()),
          );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(action == InteractionAction.liked ? 'Liked "$title"' : 'Skipped "$title"'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save: $e'), backgroundColor: Colors.redAccent),
      );
    }
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
          'No recommendations yet -- try rating a few movies first.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
