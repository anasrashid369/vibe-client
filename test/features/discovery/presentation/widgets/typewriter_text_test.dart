import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibe/features/discovery/presentation/widgets/typewriter_text.dart';

void main() {
  testWidgets('reveals text progressively over time', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TypewriterText(
            text: 'Hello world',
            startDelay: Duration(milliseconds: 100),
            charDelay: Duration(milliseconds: 50),
          ),
        ),
      ),
    );

    final initialText = tester.widget<Text>(find.byType(Text)).data;
    expect(initialText, isEmpty);

    await tester.pump(const Duration(milliseconds: 150));
    final midText = tester.widget<Text>(find.byType(Text)).data ?? '';
    expect(midText.length, greaterThan(0));
    expect(midText.length, lessThan('Hello world'.length));

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Hello world'), findsOneWidget);
  });

  testWidgets('shows full text immediately when animations are disabled', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Scaffold(
            body: TypewriterText(text: 'Hello world'),
          ),
        ),
      ),
    );

    expect(find.text('Hello world'), findsOneWidget);
  });
}
