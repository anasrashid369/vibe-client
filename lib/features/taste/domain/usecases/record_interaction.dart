import '../../data/datasources/drift_taste_local_data_source.dart';
import '../entities/interaction.dart';
import 'recompute_taste_profile.dart';

/// Writes an interaction immediately (spec §3.2 data flow), then triggers
/// an incremental taste-profile recompute every 5 interactions — not on
/// every single write, since recomputing constantly would add cost for
/// no real benefit (spec §7.1 explicitly calls out "every 5").
class RecordInteraction {
  RecordInteraction(this._dataSource, this._recompute);

  final DriftTasteLocalDataSource _dataSource;
  final RecomputeTasteProfile _recompute;

  static const _recomputeEvery = 5;

  Future<void> call(Interaction interaction) async {
    await _dataSource.recordInteraction(interaction);

    final count = await _dataSource.countInteractions();
    if (count % _recomputeEvery == 0) {
      await _recompute();
    }
  }
}