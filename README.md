# yomi_ephemeris

The **Yomi Ephemeris** — a deterministic astronomy engine. Pure Dart: embedded NASA JPL Horizons planet tables (Mercury–Pluto, Chiron) + analytic Sun/Moon/North Node + Placidus houses + aspect/transit detection. This is the exact same code the Yomi app runs, so the numbers always match.

Run it locally and your tools (Claude Code, scripts, content pipelines) can pull real natal charts and transits over `http://localhost:8080` — no guessing at astrology, ever.

> Provenance: extracted from the `astrology-app` repo (PR #13, commit `673b40d`). Accuracy is enforced by the test suite here, validated against JPL Horizons across 1900–2050.

---

## Run it locally (macOS)

You need the **Dart SDK** (3.11+). Install once:

```bash
brew tap dart-lang/dart
brew install dart
dart --version   # confirm 3.11 or newer
```

Then, from the repo:

```bash
git clone https://github.com/iguanas/yomi-ephemeris.git
cd yomi-ephemeris

dart pub get

# REQUIRED once (and after any pull): generate the freezed/json code,
# which is gitignored on purpose.
dart run build_runner build --delete-conflicting-outputs

# Start the server. The key can be anything for local use — nothing is
# exposed to the internet; it just satisfies the auth check.
EPHEMERIS_API_KEY=local-dev dart run bin/server.dart
# → "yomi_ephemeris engine vN listening on :8080"
```

Leave that terminal running while you work. To stop, Ctrl-C.

**Faster startup (optional):** compile a native binary once, then just run it — no `dart run` warmup, ideal if you're doing a lot of generations:

```bash
dart compile exe bin/server.dart -o yomi-ephemeris-server
EPHEMERIS_API_KEY=local-dev ./yomi-ephemeris-server
```

### Sanity check

```bash
# correct chart → 200
curl -sS -X POST http://localhost:8080/v1/natal \
  -H "X-Api-Key: local-dev" -H "Content-Type: application/json" \
  -d '{"datetime":"2000-01-01T12:00:00Z","location":{"latitude":40.7128,"longitude":-74.0060}}'

# no key → 401
curl -s -o /dev/null -w "%{http_code}\n" -X POST http://localhost:8080/v1/natal
```

---

## Using it from Claude Code

Tell your Claude the server is running on `http://localhost:8080` with header `X-Api-Key: local-dev`, and it can call the endpoints below directly with `curl`. A good pattern: compute the natal chart once with `/v1/natal`, save the returned `natal` object, then feed it into `/v1/transits` and `/v1/transits/batch` as many times as you need.

### Hard rules the engine enforces (these are also the brand promise)

- **Datetimes must be UTC with an explicit `Z` or offset.** `2000-01-01T12:00:00Z` ✅, `2000-01-01T12:00:00` ❌ (400). Convert local birth time to UTC before calling.
- **Supported range: 1900-01-01 .. 2050-12-31.** Outside it the engine refuses — no extrapolation, by design.
- Don't make claims the data doesn't support: nothing "accurate to the arcsecond," nothing outside 1900–2051, and the lunar node is the **mean** node.
- Every response carries `engine_version` and `node_model: "mean"`. The `/v1` prefix versions the HTTP contract.

### Endpoints

| Endpoint | Body | Returns |
|---|---|---|
| `POST /v1/natal` | `{datetime, location: {latitude, longitude, city?, country?, timezone?}, exact_time_known?: bool}` | `{natal: <chart>}` — `planetPositions` (ecliptic longitude 0–360°), 12 `houseCusps`, engine version. Set `exact_time_known: true` only when the birth time is real; when `false`, suppress Rising/house claims downstream. |
| `POST /v1/transits` | `{natal: <chart from /v1/natal, or {datetime, location}>, datetime?}` | `{at, transits: [...]}` — aspect, orb, house, peak/window timing per transit. Omit `datetime` for "now." |
| `POST /v1/transits/batch` | natal as above + `{datetimes: [...]}` **or** `{start, end, step_hours}` (step ≥ 1 min, cap 1000 results) | `{results: [{at, transits}]}` — the one to use for ranges, e.g. every day of a retrograde. |

Replayed charts are structurally validated (all planets present, 12 cusps); a chart from an older engine version returns a 400 telling you to recompute it.

---

## Validation (the parity gate)

```bash
dart test
```

`test/` checks the engine against JPL Horizons fixtures, including adversarial off-node timestamps (between table samples, at retrograde stations, at sign ingresses). Nothing that changes computed positions should ship without this passing — bump `currentEngineVersion` in `lib/astronomy/planet_position.dart` when positions change.

## Staying current

When the engine improves upstream, `git pull` and re-run `dart run build_runner build --delete-conflicting-outputs`. The `engine_version` in every response tells you which build produced a number.

## Serving it (optional)

A `Dockerfile` is included (targets Cloud Run; regenerates codegen in the build). Standing up hosted infrastructure is a founder decision — for local content work you don't need it.
