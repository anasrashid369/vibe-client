import '../../../taste/domain/entities/interaction.dart';
import '../../../taste/domain/usecases/record_interaction.dart';

/// Cold-start seeding (spec §7.1 item 1): user picks 5-8 movies during
/// onboarding, each becomes a 'liked' interaction — same code path as
/// tapping Like on the discovery screen, no special-cased logic.
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
import '../../../taste/domain/entities/interaction.dart';
import '../../../taste/domain/usecases/record_interaction.dart';

/// Cold-start seeding (spec §7.1 item 1): user picks 5-8 movies during
/// onboarding, each becomes a 'liked' interaction — same code path as
/// tapping Like on the discovery screen, no special-cased logic.
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
