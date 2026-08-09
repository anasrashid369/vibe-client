# vibe-client

Flutter client for **Vibe** — an AI-native movie discovery app. The client
never talks to an LLM or TMDB directly; every network call goes through
[`vibe-bff`](https://github.com/YOUR_ORG/vibe-bff), which owns all provider
secrets.

Full product/engineering spec lives in the project's shared docs (see
`vibe-infra/README.md` for the cross-repo overview).

## Architecture

Clean Architecture, feature-first. See `lib/`:

```
lib/
  core/        # config, network (Dio), errors, theme, routing, storage (Drift), isolates
  features/
    onboarding/    # first-run taste seeding
    discovery/     # main recommendations feed
    taste/         # interaction recording + taste profile recompute
    vibe_search/   # semantic search (Phase 2)
  app/         # DI wiring, router, root widget
```

Each feature follows `data/ -> domain/ -> presentation/`.

## State management

Riverpod. Four state categories are kept separate:
- **UI state** — ephemeral, widget-local
- **Server state** — `AsyncValue<RecommendationState>` (loading/error/fallback)
- **Persistent state** — Drift, not Riverpod
- **Session state** — in-memory, e.g. current vibe-search query

## Getting started

```bash
flutter pub get
flutter run --dart-define=ENV=dev --dart-define=BFF_BASE_URL=http://localhost:4566
```

`BFF_BASE_URL` should point at the LocalStack API Gateway endpoint started
by `vibe-infra` (see that repo's README) or your deployed BFF.

## Status

Scaffold only — Phase 0. See the roadmap below for what's next.

## Roadmap

| Phase | Focus |
|---|---|
| 0 | Repo scaffolding (this commit) |
| 1 | MVP: onboarding, taste store, single-provider BFF calls, discovery screen, rate/like/skip |
| 2 | Vibe/semantic search, multi-vendor failover, streaming reasoning field |
| 3 | Observability, CI hardening |
| 4 | Responsive layout, accessibility, full test suite |
| 5 | Real AWS deploy, multi-device sync (stretch) |

## Testing

```bash
flutter test
flutter test integration_test
```
