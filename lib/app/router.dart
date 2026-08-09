import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// TODO: import actual page widgets once features/onboarding and
// features/discovery presentation layers exist.
// import '../features/onboarding/presentation/pages/onboarding_page.dart';
// import '../features/discovery/presentation/pages/discovery_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const _Placeholder('Onboarding'),
      ),
      GoRoute(
        path: '/discovery',
        builder: (context, state) => const _Placeholder('Discovery'),
      ),
      GoRoute(
        path: '/vibe-search',
        builder: (context, state) => const _Placeholder('Vibe Search'),
      ),
    ],
  );
});

// Temporary placeholder so the app boots before real pages are wired in.
class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('$label — TODO')));
  }
}
