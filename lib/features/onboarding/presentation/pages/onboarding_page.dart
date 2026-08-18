import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../discovery/presentation/controllers/discovery_controller.dart';
import '../../onboarding_providers.dart';

const _minSelections = 5;
const _maxSelections = 8;

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final Set<int> _selected = {};
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final candidatesAsync = ref.watch(onboardingCandidatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pick a few movies you like')),
      body: candidatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Could not load movies: $error', textAlign: TextAlign.center),
          ),
        ),
        data: (movies) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Selected ${_selected.length} / $_maxSelections (need at least $_minSelections)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  final isSelected = _selected.contains(movie.id);

                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: isSelected ? '${movie.title}, selected' : movie.title,
                    child: GestureDetector(
                      onTap: () => _toggle(movie.id),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: movie.posterPath != null
                                ? Image.network(
                                    'https://image.tmdb.org/t/p/w342${movie.posterPath}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _posterFallback(movie.title),
                                  )
                                : _posterFallback(movie.title),
                          ),
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.deepPurple, width: 3),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.deepPurple.withValues(alpha: 0.25),
                              ),
                              child: const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.check_circle, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected.length >= _minSelections && !_submitting ? _submit : null,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(int movieId) {
    setState(() {
      if (_selected.contains(movieId)) {
        _selected.remove(movieId);
      } else if (_selected.length < _maxSelections) {
        _selected.add(movieId);
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await ref.read(seedInitialTasteProvider).call(_selected.toList());
    ref.invalidate(discoveryControllerProvider);
    if (mounted) context.go('/discovery');
  }

  Widget _posterFallback(String title) {
    return Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
    );
  }
}
