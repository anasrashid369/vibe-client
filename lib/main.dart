import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // ProviderScope is Riverpod's root — every ref.watch()/ref.read() call
  // anywhere in the widget tree resolves against this container. Without
  // it, none of our providers (dependencies.dart, taste_providers.dart,
  // discovery_providers.dart) would be reachable.
  runApp(const ProviderScope(child: VibeApp()));
}