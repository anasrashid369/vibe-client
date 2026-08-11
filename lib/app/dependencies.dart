// Central place to register cross-feature Riverpod providers that don't
// belong to a single feature (e.g. the Dio client, the Drift database
// instance, EnvConfig). Feature-level providers live inside each
// features/<name>/ directory instead.
//
// Kept deliberately empty at scaffold time — filled in as Phase 1 lands
// the BFF client, Drift database, and env config.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/env_config.dart';
import '../core/network/dio_client.dart';
import '../core/storage/database.dart';

/// Central place to register cross-feature Riverpod providers — the
/// Dio client, the Drift database, EnvConfig. Feature-level providers
/// live inside each features/<name>/ directory instead.

final envConfigProvider = Provider<EnvConfig>((ref) {
  return EnvConfig.fromDartDefines();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final config = ref.watch(envConfigProvider);
  return DioClient(config);
});

/// Single AppDatabase instance for the app's lifetime — Drift manages
/// its own connection pooling internally, so one instance is correct,
/// not a connection-per-request pattern.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});