import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibe/features/discovery/domain/entities/movie.dart';
import 'package:vibe/features/onboarding/onboarding_providers.dart';
import 'package:vibe/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  final movies = List.generate(
    8,
    (i) => Movie(id: i, title: 'Movie $i', overview: 'Overview $i', posterPath: null, genres: const []),
  );

  Widget wrap() {
    return ProviderScope(
      overrides: [
        onboardingCandidatesProvider.overrideWith((ref) async => movies),
      ],
      child: const MaterialApp(home: OnboardingPage()),
    );
  }

  Future<void> _pump(WidgetTester tester) async {
    // Tall surface so the 3-column grid builds enough rows for tap tests.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
  }

  testWidgets('renders movie grid with title fallbacks (no poster)', (tester) async {
    await _pump(tester);

    expect(find.text('Movie 0'), findsOneWidget);
    expect(find.text('Selected 0 / 8 (need at least 5)'), findsOneWidget);
  });

  testWidgets('Continue button stays disabled until 5 are selected', (tester) async {
    await _pump(tester);

    final continueButton = find.widgetWithText(FilledButton, 'Continue');
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Movie $i'));
      await tester.pump();
    }

    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
  });

  testWidgets('selecting a movie shows the selected checkmark', (tester) async {
    await _pump(tester);

    expect(find.byIcon(Icons.check_circle), findsNothing);

    await tester.tap(find.text('Movie 0'));
    await tester.pump();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
