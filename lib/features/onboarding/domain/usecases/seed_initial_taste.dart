import '../../../taste/domain/entities/interaction.dart';
import '../../../taste/domain/usecases/record_interaction.dart';

class SeedInitialTaste {
  SeedInitialTaste(this._recordInteraction);

  final RecordInteraction _recordInteraction;

  Future<void> call(List<int> selectedMovieIds) async {
    for (final movieId in selectedMovieIds) {
      await _recordInteraction(
        Interaction(movieId: movieId, action: InteractionAction.liked, createdAt: DateTime.now()),
      );
    }
  }
}
