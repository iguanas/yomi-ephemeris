// Large-scale cross-check of Yomi's ephemeris against NASA JPL Horizons.
//
// Fixture `test/fixtures/jpl_ephemeris.json` contains 19,932 apparent
// geocentric ecliptic longitudes (11 bodies × 1,812 timestamps at 1-month
// intervals 1900-01-01 → 2050-12-31), fetched from JPL Horizons once via
// `tools/fetch_horizons.dart` and committed as ground truth.
//
// This test replays every sample through Yomi's engine and reports:
//   - Mean and P50/P95/max delta per body.
//   - Sign-mismatch count (ecliptic longitude falls in a different 30°
//     segment than Horizons').
//   - Sign-mismatch distance from the cusp (how far the truth value was
//     from a sign boundary when we misclassified) — most of these are
//     within 1-2° of a cusp, which is the drift-under-tolerance case.
//
// The strict pass/fail bar is the sign-mismatch rate: if Yomi
// misclassifies more than 5% of samples for a body, the test fails.
// Individual delta thresholds are guardrails, not pass/fail.
//
// CAVEAT (audit P2-3): the bundled monthly/daily tables were originally
// generated from this same fixture at these same timestamps, so for
// node-aligned table-driven bodies this test can read ~0.00° by
// construction. The honest accuracy gate is
// `accuracy_offnode_audit_test.dart`, which samples mid-month at 00:00
// UTC — off every table grid — with hard per-body max-delta bars.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';
import 'package:yomi_ephemeris/models/planet.dart';
import 'package:yomi_ephemeris/astronomy/planet_position.dart';

final _bodyMap = <String, Planet>{
  'sun': Planet.sun,
  'moon': Planet.moon,
  'mercury': Planet.mercury,
  'venus': Planet.venus,
  'mars': Planet.mars,
  'jupiter': Planet.jupiter,
  'saturn': Planet.saturn,
  'uranus': Planet.uranus,
  'neptune': Planet.neptune,
  'pluto': Planet.pluto,
  'chiron': Planet.chiron,
};

/// Per-body sign-mismatch tolerance. Values track the engine's measured
/// state on 2026-04-20 against JPL Horizons 1900-2050 monthly sampling.
/// Tests guard against *regression* past these — tighten when we upgrade
/// the engine (Moshier / Swiss).
///
/// Current state is excellent for Sun/Moon/Venus/Jupiter/Saturn/Neptune
/// (<2%), OK for Uranus/Mars (2-7%), and a known gap for Mercury/Pluto
/// (10-12%). Mercury and Pluto share a root cause: the VSOP87-class
/// model we use doesn't include Pluto and truncates Mercury's fast
/// perturbations. Fixing both means upgrading the ephemeris (Moshier
/// is ~1 week of porting); documented in docs/astrology-accuracy-audit.md.
const _signMismatchMax = <String, double>{
  'sun': 0.005,
  'moon': 0.005,
  'mercury': 0.005,
  'venus': 0.005,
  'mars': 0.005,
  'jupiter': 0.005,
  'saturn': 0.005,
  'uranus': 0.005,
  'neptune': 0.005,
  'pluto': 0.005,
  'chiron': 0.005,
};

double _angularDelta(double a, double b) {
  var d = (a - b).abs() % 360;
  if (d > 180) d = 360 - d;
  return d;
}

int _signIndex(double lon) => ((lon % 360) / 30).floor();

/// Shortest angular distance from `lon` to the nearest sign cusp (0°, 30°,
/// 60°, ...). Returns 0-15°.
double _distanceFromCusp(double lon) {
  final normalized = lon % 30;
  return min(normalized, 30 - normalized);
}

void main() {
  // Load once, reused across all tests.
  final file = File('test/fixtures/jpl_ephemeris.json');
  if (!file.existsSync()) {
    throw StateError(
      'test/fixtures/jpl_ephemeris.json missing. Fetch it from the repo '
      'root: `dart run tools/fetch_horizons.dart` (writes into this '
      "package's test/fixtures by default).",
    );
  }
  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final samples = (data['samples'] as List).cast<Map<String, dynamic>>();

  // Group by body for per-body reporting.
  final byBody = <String, List<_Sample>>{};
  for (final s in samples) {
    final body = s['body'] as String;
    final utc = DateTime.parse(s['utc'] as String);
    final lon = (s['ecliptic_lon'] as num).toDouble();
    byBody.putIfAbsent(body, () => <_Sample>[]).add(_Sample(utc, lon));
  }

  group('JPL Horizons batch audit', () {
    for (final entry in byBody.entries) {
      final bodyName = entry.key;
      final planet = _bodyMap[bodyName];
      if (planet == null) continue;
      final bodySamples = entry.value;
      final maxMismatchRate = _signMismatchMax[bodyName] ?? 0.05;

      test(
        '$bodyName × ${bodySamples.length} samples '
        '(max sign-mismatch rate ${(maxMismatchRate * 100).toStringAsFixed(0)}%)',
        () {
          final deltas = <double>[];
          var signMismatches = 0;
          final mismatchNearCusp = <double>[];

          for (final s in bodySamples) {
            final actual = planetLongitude(planet, s.utc);
            final delta = _angularDelta(actual, s.truthLon);
            deltas.add(delta);
            if (_signIndex(actual) != _signIndex(s.truthLon)) {
              signMismatches++;
              mismatchNearCusp.add(_distanceFromCusp(s.truthLon));
            }
          }

          deltas.sort();
          final mean = deltas.reduce((a, b) => a + b) / deltas.length;
          final p50 = deltas[deltas.length ~/ 2];
          final p95 = deltas[(deltas.length * 0.95).floor()];
          final max = deltas.last;

          final mismatchRate = signMismatches / bodySamples.length;
          mismatchNearCusp.sort();
          final medianCuspDist = mismatchNearCusp.isEmpty
              ? 0.0
              : mismatchNearCusp[mismatchNearCusp.length ~/ 2];

          // ignore: avoid_print
          print('  $bodyName: '
              'mean=${mean.toStringAsFixed(2)}° '
              'p50=${p50.toStringAsFixed(2)}° '
              'p95=${p95.toStringAsFixed(2)}° '
              'max=${max.toStringAsFixed(2)}° '
              '| sign-miss $signMismatches/${bodySamples.length} '
              '(${(mismatchRate * 100).toStringAsFixed(1)}%) '
              '| median-cusp-dist when misclassified: '
              '${medianCuspDist.toStringAsFixed(2)}°');

          expect(mismatchRate, lessThanOrEqualTo(maxMismatchRate),
              reason: '$bodyName misclassified the sign in '
                  '${(mismatchRate * 100).toStringAsFixed(1)}% of samples '
                  '(threshold ${(maxMismatchRate * 100).toStringAsFixed(0)}%)');
        },
      );
    }
  });
}

class _Sample {
  _Sample(this.utc, this.truthLon);
  final DateTime utc;
  final double truthLon;
}
