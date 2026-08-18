import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibe/features/discovery/domain/entities/recommendation.dart';
import 'package:vibe/features/discovery/presentation/widgets/recommendation_card.dart';

void main() {
  const recommendation = Recommendation(
    movieId: 1,
    title: 'Test Movie',
    reason: 'A gripping tale of testing.',
    confidence: 'high',
    posterPath: null,
    genres: ['Drama'],
  );

  testWidgets('renders title and reveals reason text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            recommendation: recommendation,
            onLike: () {},
            onSkip: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Movie'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(seconds: 2));

    expect(find.textContaining('A gripping tale of testing.'), findsOneWidget);
  });

  testWidgets('tapping Like calls onLike', (tester) async {
    var liked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            recommendation: recommendation,
            onLike: () => liked = true,
            onSkip: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Like'));
    expect(liked, isTrue);
  });

  testWidgets('tapping Skip calls onSkip', (tester) async {
    var skipped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            recommendation: recommendation,
            onLike: () {},
            onSkip: () => skipped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Skip'));
    expect(skipped, isTrue);
  });

  testWidgets('shows fallback icon when posterPath is null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            recommendation: recommendation,
            onLike: () {},
            onSkip: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.movie), findsOneWidget);
  });
}
