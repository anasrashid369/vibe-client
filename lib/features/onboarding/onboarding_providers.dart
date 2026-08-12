import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../discovery/discovery_providers.dart';
import '../discovery/domain/entities/movie.dart';
import '../taste/taste_providers.dart';
import 'domain/usecases/seed_initial_taste.dart';

final onboardingCandidatesProvider =
    FutureProvider.autoDispose<List<Movie>>((ref) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  final result = await repo.getCandidates();
  return result.when(ok: (movies) => movies, err: (error) => throw error);
});

final seedInitialTasteProvider = Provider<SeedInitialTaste>((ref) {
  return SeedInitialTaste(ref.watch(recordInteractionProvider));
});
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../discovery/discovery_providers.dart';
import '../discovery/domain/entities/movie.dart';
import '../taste/taste_providers.dart';
import 'domain/usecases/seed_initial_taste.dart';

final onboardingCandidatesProvider = FutureProvider.autoDispose<List<Movie>>((ref) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  final result = await repo.getCandidates();
  return result.when(ok: (movies) => movies, err: (error) => throw error);
});

final seedInitialTasteProvider = Provider<SeedInitialTaste>((ref) {
  return SeedInitialTaste(ref.watch(recordInteractionProvider));
});
