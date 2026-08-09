// Central place to register cross-feature Riverpod providers that don't
// belong to a single feature (e.g. the Dio client, the Drift database
// instance, EnvConfig). Feature-level providers live inside each
// features/<name>/ directory instead.
//
// Kept deliberately empty at scaffold time — filled in as Phase 1 lands
// the BFF client, Drift database, and env config.
