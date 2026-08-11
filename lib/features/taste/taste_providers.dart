import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dependencies.dart';
import 'data/datasources/drift_taste_local_data_source.dart';
import 'domain/usecases/recompute_taste_profile.dart';
import 'domain/usecases/record_interaction.dart';

final tasteLocalDataSourceProvider = Provider<DriftTasteLocalDataSource>((ref) {
  return DriftTasteLocalDataSource(ref.watch(databaseProvider));
});

final recomputeTasteProfileProvider = Provider<RecomputeTasteProfile>((ref) {
  return RecomputeTasteProfile(ref.watch(tasteLocalDataSourceProvider));
});

final recordInteractionProvider = Provider<RecordInteraction>((ref) {
  return RecordInteraction(
    ref.watch(tasteLocalDataSourceProvider),
    ref.watch(recomputeTasteProfileProvider),
  );
});