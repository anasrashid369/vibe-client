# vibe-client

Flutter client for **Vibe** — an AI-native movie discovery app. The client
never talks to an LLM or TMDB directly; every network call goes through
[`vibe-bff`](https://github.com/anasrashid369/vibe-bff), which owns all
provider secrets.

## Status: Feature-complete MVP + Phase 2 extensions

### Implemented
- **Onboarding** — curated poster grid, pick 5–8 movies, seeds initial taste
- **Discovery ("For You")** — AI-curated recommendations with real posters,
  genres, and a typewriter reveal animation on the reasoning text
- **Rate/Like/Skip** — writes to local Drift storage, feeds back into taste
  profile and future recommendation requests (`recentLikes`/`excludeIds`)
- **Vibe Search** — free-text mood search using on-device semantic
  (cosine-similarity) matching against locally cached movie embeddings
- **Responsive layout** — single-column list on narrow windows, grid on wide
- **Accessibility** — semantic labels on interactive elements, reduced-motion
  support for the reveal animation
- **Error/loading/empty states** — explicit UI for every discovery state
- **Widget test suite** — covers all four discovery states, onboarding
  selection logic, and the reveal animation

## Architecture

Clean Architecture, feature-first. See `lib/`:

lib/
core/ # config, network (Dio), errors, theme, routing, storage (Drift)
features/
onboarding/ # first-run taste seeding
discovery/ # main recommendations feed + vibe search entry
taste/ # interaction recording + taste profile recompute
vibe_search/ # semantic search (embeddings, isolate cosine search)
app/ # DI wiring, router, home shell (bottom nav)


Each feature follows `data/ -> domain/ -> presentation/`. State management:
Riverpod (`AsyncNotifier` for server state).

## Local database (Drift)

Four tables: `movies_cache`, `interactions`, `taste_profile`,
`movie_embeddings`. All local, single-device, no sync (matches MVP scope).
Regenerate the generated Drift/Freezed code after any schema/model change:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Getting started

```bash
flutter pub get
flutter create --platforms=windows .   # one-time, if windows/ is missing
flutter run -d windows --dart-define=BFF_BASE_URL=<your-bff-url>
```

`BFF_BASE_URL` should point at your deployed BFF's base path (LocalStack
API Gateway locally, or a real deployment).

## Testing

```bash
flutter analyze
flutter test
```

## Known limitations
- Real network token-streaming for the reasoning field isn't implemented —
  API Gateway buffers full Lambda responses, so streaming would require
  Lambda Function URLs (a different invocation path). The reveal animation
  is a client-side effect over complete data, documented as such in
  `typewriter_text.dart`.
- `RecomputeTasteProfile` derives genres from locally cached movies; very
  fresh installs with few interactions will have limited signal.
