// OFF-NODE cross-check of Yomi's ephemeris against NASA JPL Horizons.
//
// Why this exists (audit P2-3): the bundled planet tables were generated
// from `jpl_ephemeris.json` at the SAME timestamps that
// `accuracy_batch_audit_test.dart` validates against, so for every
// table-driven body that test reads 0.00° by construction — a frame
// error or table-pipeline bug would stay green. This was exactly why the
// Chiron defect (~180° wrong for every user) lived in production for so
// long: Chiron wasn't in the batch audit at all, and the audit couldn't
// have caught a table bug anyway.
//
// Fixture `jpl_ephemeris_offnode.json` samples the 15th of each month at
// 00:00 UTC, 1900-2050 (1,812 timestamps x 11 bodies) — deliberately OFF
// the bundled tables' sample nodes (daily/weekly/monthly grids anchored
// at 12:00 UTC), so every comparison exercises real interpolation
// against independently fetched truth. Refetch (from the REPO ROOT — the
// fetch tool lives in the app repo's tools/, not this package):
//   dart run tools/fetch_horizons.dart --step 1mo \
//     --start "1900-01-15 00:00" --stop "2050-12-15 00:00" \
//     --out packages/yomi_ephemeris/test/fixtures/jpl_ephemeris_offnode.json
//
// Pass bar: hard per-body MAX delta (not a sign-mismatch rate). The
// thresholds are ~2-4x the measured 2026-06 worst case for each body, so
// a real regression trips them while normal interpolation noise never
// does. Measured worst (2026-06, weekly outer tables): Sun 0.013°, Moon
// 0.063°, Mercury 0.024°, Venus 0.005°, Mars 0.002°, Jupiter 0.021°,
// Saturn 0.011°, Uranus 0.005°, Neptune 0.004°, Pluto 0.003°, Chiron
// 0.23° (monthly table, 1996 perihelion).

import 'dart:convert';
import 'dart:io';

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

/// Hard max-delta bar per body, in degrees.
const _maxDelta = <String, double>{
  'sun': 0.1,
  'moon': 0.1,
  'mercury': 0.1,
  'venus': 0.1,
  'mars': 0.1,
  'jupiter': 0.1,
  'saturn': 0.1,
  'uranus': 0.1,
  'neptune': 0.1,
  'pluto': 0.1,
  'chiron': 0.3, // monthly table; 0.23° measured at the 1996 perihelion
};

double _angularDelta(double a, double b) {
  var d = (a - b).abs() % 360;
  if (d > 180) d = 360 - d;
  return d;
}

void main() {
  final file = File('test/fixtures/jpl_ephemeris_offnode.json');
  if (!file.existsSync()) {
    throw StateError(
      'test/fixtures/jpl_ephemeris_offnode.json missing. See the header '
      'of this test for the fetch command.',
    );
  }
  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final samples = (data['samples'] as List).cast<Map<String, dynamic>>();

  final byBody = <String, List<_Sample>>{};
  for (final s in samples) {
    byBody.putIfAbsent(s['body'] as String, () => <_Sample>[]).add(_Sample(
          DateTime.parse(s['utc'] as String),
          (s['ecliptic_lon'] as num).toDouble(),
        ));
  }

  group('JPL Horizons OFF-NODE batch audit', () {
    test('fixture covers all 11 bodies at mid-month timestamps', () {
      expect(byBody.keys.toSet(), _bodyMap.keys.toSet());
      for (final entry in byBody.entries) {
        expect(entry.value.length, greaterThanOrEqualTo(1800),
            reason: '${entry.key} should span 1900-2050 monthly');
        // Every sample must sit OFF the bundled tables' 12:00 UTC grid —
        // that offset is the whole point of this fixture.
        expect(entry.value.every((s) => s.utc.hour == 0), isTrue,
            reason: '${entry.key} has samples on the table-node grid');
      }
    });

    for (final entry in _bodyMap.entries) {
      final bodyName = entry.key;
      final planet = entry.value;
      final bar = _maxDelta[bodyName]!;

      test('$bodyName max delta ≤ $bar° at off-node timestamps', () {
        final bodySamples = byBody[bodyName]!;
        var max = 0.0;
        DateTime? maxAt;
        var sum = 0.0;
        for (final s in bodySamples) {
          final d = _angularDelta(planetLongitude(planet, s.utc), s.truthLon);
          sum += d;
          if (d > max) {
            max = d;
            maxAt = s.utc;
          }
        }
        final mean = sum / bodySamples.length;
        // ignore: avoid_print
        print('  $bodyName: mean=${mean.toStringAsFixed(3)}° '
            'max=${max.toStringAsFixed(3)}° at ${maxAt?.toIso8601String()} '
            '(bar $bar°, n=${bodySamples.length})');
        expect(max, lessThanOrEqualTo(bar),
            reason: '$bodyName drifted to ${max.toStringAsFixed(3)}° at '
                '$maxAt against independent off-node JPL data '
                '(bar $bar°)');
      });
    }
  });
}

class _Sample {
  _Sample(this.utc, this.truthLon);
  final DateTime utc;
  final double truthLon;
}
