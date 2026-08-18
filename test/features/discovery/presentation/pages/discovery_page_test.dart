import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibe/core/errors/app_exception.dart';
import 'package:vibe/features/discovery/domain/entities/recommendation.dart';
import 'package:vibe/features/discovery/domain/entities/recommendation_result.dart';
import 'package:vibe/features/discovery/presentation/controllers/discovery_controller.dart';
import 'package:vibe/features/discovery/presentation/pages/discovery_page.dart';

class _FixedDiscoveryController extends DiscoveryController {
  _FixedDiscoveryController(this._behavior);
  final Future<RecommendationResult> Function() _behavior;

  @override
  Future<RecommendationResult> build() => _behavior();
}

Widget _wrap(Override override) {
  return ProviderScope(
    overrides: [override],
    child: const MaterialApp(home: DiscoveryPage()),
  );
}

void main() {
  testWidgets('shows loading spinner while fetching', (tester) async {
    await tester.pumpWidget(
      _wrap(
        discoveryControllerProvider.overrideWith(
          () => _FixedDiscoveryController(() => Completer<RecommendationResult>().future),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error state with retry button', (tester) async {
    await tester.pumpWidget(
      _wrap(
        discoveryControllerProvider.overrideWith(
          () => _FixedDiscoveryController(() async => throw const NetworkException()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No network connection.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no recommendations', (tester) async {
    await tester.pumpWidget(
      _wrap(
        discoveryControllerProvider.overrideWith(
          () => _FixedDiscoveryController(
            () async => const RecommendationResult(
              source: RecommendationSource.ai,
              providerUsed: 'test-provider',
              recommendations: [],
              fallbackTriggered: false,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('No recommendations yet'), findsOneWidget);
  });

  testWidgets('shows recommendation cards and AI badge when data loads', (tester) async {
    await tester.pumpWidget(
      _wrap(
        discoveryControllerProvider.overrideWith(
          () => _FixedDiscoveryController(
            () async => const RecommendationResult(
              source: RecommendationSource.ai,
              providerUsed: 'test-provider',
              recommendations: [
                Recommendation(
                  movieId: 1,
                  title: 'Movie A',
                  reason: 'Reason A',
                  confidence: 'high',
                ),
              ],
              fallbackTriggered: false,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('AI-curated'), findsOneWidget);
    expect(find.text('Movie A'), findsOneWidget);
  });
}
