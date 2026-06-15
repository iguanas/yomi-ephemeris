// Comprehensive astrological accuracy audit.
//
// This suite cross-checks Yomi's hand-rolled Dart ephemeris against
// publicly-verifiable reference values (Swiss Ephemeris / JPL Horizons /
// Astrodienst). When a case fails, the diagnostic output shows exactly
// how far off each subsystem is, so we can decide whether to tighten
// the math, swap in Moshier/Swiss, or loosen tolerance.
//
// Organised by subsystem:
//   1. Planet positions at J2000.0 (well-known reference epoch)
//   2. Planet positions at 2024-01-01 00:00 UTC (modern reference)
//   3. Sun-sign ingress dates (Sun crosses 0°, 30°, ..., 330° exactly)
//   4. Moon sign + speed sanity
//   5. House cusps and ascendant for synthetic birth data
//   6. Aspect detection symmetry
//   7. Ingress-day edge cases (the "dad says his sign is wrong" scenario)
//
// Tolerances: ±0.5° for every body (see _tolerance). The engine is
// table-driven (JPL Horizons) for Mercury–Pluto and Chiron and measures
// <0.1° off-node for all of them (2026-06 audit), so 0.5° is a loose
// regression guard, not an accuracy claim. House cusps ±0.5° from the
// Placidus reference; Ascendant ±0.5°.

import 'dart:math';

import 'package:test/test.dart';
import 'package:yomi_ephemeris/models/aspect.dart';
import 'package:yomi_ephemeris/models/geo_location.dart';
import 'package:yomi_ephemeris/models/planet.dart';
import 'package:yomi_ephemeris/astronomy/aspect_detector.dart';
import 'package:yomi_ephemeris/astronomy/house_calculator.dart';
import 'package:yomi_ephemeris/astronomy/planet_position.dart';

// ---- Reference ephemeris data -------------------------------------------

/// Ecliptic longitude of each planet at the J2000.0 epoch
/// (2000-01-01 12:00:00 UTC, geocentric, tropical, apparent of-date).
///
/// Source: NASA JPL Horizons (ObsEcLon, quantity 31, CENTER 500@399),
/// fetched 2026-06-09. The previous constants were eyeballed from mixed
/// sources and were off by up to 6.0° (Moon 217.32 vs true 223.32) with
/// tolerances padded to match — the 2026-06 audit measured the ENGINE
/// within 0.1° of JPL while this test data was the thing that was wrong
/// (audit P2-2). North Node is the MEAN node: the engine ships mean by
/// design (audit P2-8); Horizons has no mean-node body, so the published
/// Meeus J2000 constant (Ω = 125.0445°) is the reference.
const Map<Planet, double> _j2000 = {
  Planet.sun: 280.37,
  Planet.moon: 223.32,
  Planet.mercury: 271.89,
  Planet.venus: 241.57,
  Planet.mars: 327.96,
  Planet.jupiter: 25.25,
  Planet.saturn: 40.40,
  Planet.uranus: 314.81,
  Planet.neptune: 303.19,
  Planet.pluto: 251.45,
  Planet.chiron: 251.62,
  Planet.northNode: 125.04, // Meeus mean node at J2000.0
};

/// Ecliptic longitude at 2024-01-01 00:00:00 UTC.
/// Source: NASA JPL Horizons (same query shape as [_j2000]), fetched
/// 2026-06-09. Replaces the wrong Venus 247.30 (true 242.61) and Mars
/// 262.80 (true 267.31) — audit P2-2: the engine was right and the old
/// test data was wrong, with tolerances padded to 5° to make it pass.
const Map<Planet, double> _jan2024 = {
  Planet.sun: 280.04,
  Planet.moon: 155.99,
  Planet.mercury: 262.28,
  Planet.venus: 242.61,
  Planet.mars: 267.31,
  Planet.jupiter: 35.58,
  Planet.saturn: 333.24,
  Planet.uranus: 49.38,
  Planet.neptune: 355.08,
  Planet.pluto: 299.36,
  Planet.chiron: 15.46,
};

/// Exact UTC timestamps when the Sun enters each tropical sign in 2024.
/// At these moments the Sun's ecliptic longitude is an exact multiple of 30°
/// (mod 360). Source: US Naval Observatory / Astrodienst.
final List<({DateTime time, double expectedLongitude, String sign})>
    _ingress2024 = [
  (time: DateTime.utc(2024, 3, 20, 3, 6), expectedLongitude: 0, sign: 'Aries'),
  (
    time: DateTime.utc(2024, 4, 19, 13, 59),
    expectedLongitude: 30,
    sign: 'Taurus'
  ),
  (
    time: DateTime.utc(2024, 5, 20, 12, 59),
    expectedLongitude: 60,
    sign: 'Gemini'
  ),
  (
    time: DateTime.utc(2024, 6, 20, 20, 51),
    expectedLongitude: 90,
    sign: 'Cancer'
  ),
  (time: DateTime.utc(2024, 7, 22, 7, 44), expectedLongitude: 120, sign: 'Leo'),
  (
    time: DateTime.utc(2024, 8, 22, 14, 54),
    expectedLongitude: 150,
    sign: 'Virgo'
  ),
  (
    time: DateTime.utc(2024, 9, 22, 12, 43),
    expectedLongitude: 180,
    sign: 'Libra'
  ),
  (
    time: DateTime.utc(2024, 10, 22, 22, 14),
    expectedLongitude: 210,
    sign: 'Scorpio'
  ),
  (
    time: DateTime.utc(2024, 11, 21, 20, 56),
    expectedLongitude: 240,
    sign: 'Sagittarius'
  ),
  (
    time: DateTime.utc(2024, 12, 21, 9, 20),
    expectedLongitude: 270,
    sign: 'Capricorn'
  ),
];

// ---- Helpers ------------------------------------------------------------

/// Angular difference on a 360° circle — returns 0-180.
double _angularDelta(double a, double b) {
  var d = (a - b).abs() % 360;
  if (d > 180) d = 360 - d;
  return d;
}

/// Guardrail tolerance — the bar below which we consider the engine
/// misbehaving. Tightened 2026-06 (audit P2-2) from 2-10° per body to a
/// flat 0.5°: the old wide bands existed to make wrong reference data
/// pass. Measured engine error vs JPL off-node is <0.1° for every body
/// (Chiron <0.3°), so 0.5° still leaves headroom while catching any
/// real regression (a table pipeline bug, a frame error, a sign flip).
double _tolerance(Planet p) => 0.5;

/// Tropical sign index 0-11 (Aries=0, Pisces=11) for a longitude.
int _signIndex(double lon) => ((lon % 360) / 30).floor();

const _signs = [
  'Aries',
  'Taurus',
  'Gemini',
  'Cancer',
  'Leo',
  'Virgo',
  'Libra',
  'Scorpio',
  'Sagittarius',
  'Capricorn',
  'Aquarius',
  'Pisces',
];

void main() {
  group('Planet positions — J2000.0 epoch', () {
    final j2000 = DateTime.utc(2000, 1, 1, 12, 0, 0);
    _j2000.forEach((planet, expected) {
      test('${planet.name} at J2000.0 within ${_tolerance(planet)}°', () {
        final actual = planetLongitude(planet, j2000);
        final delta = _angularDelta(actual, expected);
        if (delta > _tolerance(planet)) {
          fail('${planet.name}: expected $expected°, got '
              '${actual.toStringAsFixed(2)}°, delta ${delta.toStringAsFixed(2)}° '
              '(tolerance ${_tolerance(planet)}°)');
        }
      });
    });
  });

  group('Planet positions — 2024-01-01 00:00 UT', () {
    final dt = DateTime.utc(2024, 1, 1, 0, 0, 0);
    _jan2024.forEach((planet, expected) {
      test('${planet.name} at 2024-01-01 within ${_tolerance(planet)}°', () {
        final actual = planetLongitude(planet, dt);
        final delta = _angularDelta(actual, expected);
        if (delta > _tolerance(planet)) {
          fail('${planet.name}: expected $expected°, got '
              '${actual.toStringAsFixed(2)}°, delta ${delta.toStringAsFixed(2)}° '
              '(tolerance ${_tolerance(planet)}°) — sign assigned '
              '"${_signs[_signIndex(actual)]}", should be '
              '"${_signs[_signIndex(expected)]}"');
        }
      });
    });
  });

  group('Sun-sign ingresses 2024 — sign assignment at the exact ingress moment',
      () {
    for (final ingress in _ingress2024) {
      test('Sun at ${ingress.sign} ingress ${ingress.time.toIso8601String()}',
          () {
        final lon = planetLongitude(Planet.sun, ingress.time);
        final delta = _angularDelta(lon, ingress.expectedLongitude);
        if (delta > 0.5) {
          fail('Sun longitude at ${ingress.sign} ingress: expected '
              '${ingress.expectedLongitude}°, got ${lon.toStringAsFixed(3)}°, '
              'delta ${delta.toStringAsFixed(3)}° (tolerance 0.5°). '
              'Off by ${(delta / 0.986).toStringAsFixed(1)} days.');
        }
      });
    }
  });

  group('Sun-sign edge cases — users born near an ingress day', () {
    // Taurus-Gemini cutoff 2024: Sun ingresses Gemini at May 20 12:59 UT.
    // A user born May 20 at 09:00 UT should be Taurus; born May 20 at 18:00 UT
    // should be Gemini. This is the exact scenario where a wrong engine
    // misclassifies someone's Sun sign.
    test('May 20 2024 09:00 UT → Sun in Taurus (not Gemini)', () {
      final before = DateTime.utc(2024, 5, 20, 9, 0);
      final lon = planetLongitude(Planet.sun, before);
      expect(_signIndex(lon), equals(1),
          reason: 'Expected Taurus (idx 1), got ${_signs[_signIndex(lon)]} '
              'at longitude ${lon.toStringAsFixed(3)}°');
    });
    test('May 20 2024 18:00 UT → Sun in Gemini (not Taurus)', () {
      final after = DateTime.utc(2024, 5, 20, 18, 0);
      final lon = planetLongitude(Planet.sun, after);
      expect(_signIndex(lon), equals(2),
          reason: 'Expected Gemini (idx 2), got ${_signs[_signIndex(lon)]} '
              'at longitude ${lon.toStringAsFixed(3)}°');
    });

    // Libra-Scorpio cutoff 2024: Sun ingresses Scorpio at Oct 22 22:14 UT.
    test('Oct 22 2024 18:00 UT → Sun in Libra (not Scorpio)', () {
      final before = DateTime.utc(2024, 10, 22, 18, 0);
      final lon = planetLongitude(Planet.sun, before);
      expect(_signIndex(lon), equals(6),
          reason: 'Expected Libra (idx 6), got ${_signs[_signIndex(lon)]} '
              'at longitude ${lon.toStringAsFixed(3)}°');
    });
    test('Oct 23 2024 03:00 UT → Sun in Scorpio (not Libra)', () {
      final after = DateTime.utc(2024, 10, 23, 3, 0);
      final lon = planetLongitude(Planet.sun, after);
      expect(_signIndex(lon), equals(7),
          reason: 'Expected Scorpio (idx 7), got ${_signs[_signIndex(lon)]} '
              'at longitude ${lon.toStringAsFixed(3)}°');
    });
  });

  group('Moon — speed and continuity', () {
    test('Moon travels ~13°/day on average over a full synodic month', () {
      final start = DateTime.utc(2024, 6, 1, 0, 0);
      final end = DateTime.utc(2024, 6, 29, 0, 0); // 28 days
      final startLon = planetLongitude(Planet.moon, start);
      final endLon = planetLongitude(Planet.moon, end);
      // Moon wraps: find total sweep.
      var swept = (endLon - startLon) % 360;
      if (swept < 0) swept += 360;
      // In 28 days Moon sweeps about 28 * 13.176° = 368.93° → wrap to 8.93°
      final totalDegrees = 28 * 13.176;
      final wrapped = totalDegrees % 360;
      final delta = (swept - wrapped).abs();
      expect(delta, lessThan(5.0),
          reason: 'Moon swept ${swept.toStringAsFixed(2)}° in 28 days, '
              'expected ${wrapped.toStringAsFixed(2)}° '
              '(delta ${delta.toStringAsFixed(2)}°)');
    });

    test('Moon daily step is always 10°-16° (no discontinuities)', () {
      final start = DateTime.utc(2024, 6, 1, 0, 0);
      for (var day = 0; day < 30; day++) {
        final a = planetLongitude(
            Planet.moon, start.add(Duration(days: day)));
        final b = planetLongitude(
            Planet.moon, start.add(Duration(days: day + 1)));
        var step = (b - a) % 360;
        if (step < 0) step += 360;
        expect(step, greaterThan(10),
            reason: 'Day $day step = $step° (too small)');
        expect(step, lessThan(16),
            reason: 'Day $day step = $step° (too big, data jump?)');
      }
    });
  });

  group('House cusps — synthetic birth data', () {
    // Synthetic chart: equator at longitude 0, noon UT, June solstice.
    // On the equator at noon local time, the Sun (~90° at summer solstice)
    // should be near the MC (10th house cusp).
    test('equator + solstice noon UT: MC near 90° (Sun near MC)', () {
      final calc = HouseCalculator();
      final dt = DateTime.utc(2024, 6, 20, 12, 0);
      final loc = const GeoLocation(
        latitude: 0,
        longitude: 0,
        cityName: 'null-island',
        countryCode: 'null',
        timezone: 'UTC',
      );
      final cusps = calc.calculateCusps(dt, loc);
      // MC is cusp index 9 (10th house).
      final mc = cusps[9];
      final sunLon = planetLongitude(Planet.sun, dt);
      final delta = _angularDelta(mc, sunLon);
      expect(delta, lessThan(5),
          reason: 'MC=${mc.toStringAsFixed(2)}°, '
              'Sun=${sunLon.toStringAsFixed(2)}°, '
              'delta=${delta.toStringAsFixed(2)}° — '
              'at noon UT on the equator the Sun should sit near the MC');
    });

    test('12 cusps are distinct, ordered, spanning the full zodiac', () {
      final calc = HouseCalculator();
      final dt = DateTime.utc(1990, 6, 15, 14, 30);
      final loc = const GeoLocation(
        latitude: 40.7,
        longitude: -74.0,
        cityName: 'new-york',
        countryCode: 'us',
        timezone: 'America/New_York',
      );
      final cusps = calc.calculateCusps(dt, loc);
      expect(cusps.length, equals(12));
      // No two cusps within 1° of each other.
      for (var i = 0; i < 12; i++) {
        for (var j = i + 1; j < 12; j++) {
          final delta = _angularDelta(cusps[i], cusps[j]);
          expect(delta, greaterThan(1),
              reason: 'Cusps $i and $j are too close: '
                  '${cusps[i].toStringAsFixed(2)}°, '
                  '${cusps[j].toStringAsFixed(2)}° '
                  '(delta ${delta.toStringAsFixed(2)}°)');
        }
      }
      // Houses progress *forward* on the ecliptic: starting at ASC and
      // going through rising ecliptic longitudes we pass h2, h3, IC (h4),
      // h5, h6, DESC, h8, h9, MC, h11, h12, back to ASC. Each step
      // should advance 15-60° forward.
      for (var i = 1; i < 12; i++) {
        final forward = (cusps[i] - cusps[i - 1] + 360) % 360;
        expect(forward, greaterThan(15),
            reason: 'Forward gap ${i - 1} → $i is '
                '${forward.toStringAsFixed(2)}° (too small)');
        expect(forward, lessThan(60),
            reason: 'Forward gap ${i - 1} → $i is '
                '${forward.toStringAsFixed(2)}° (too big)');
      }
      // Twelve forward arcs should sum to exactly 360°.
      var total = 0.0;
      for (var i = 0; i < 12; i++) {
        final next = (i + 1) % 12;
        total += (cusps[next] - cusps[i] + 360) % 360;
      }
      expect(total, closeTo(360, 0.5));
    });

    test('Ascendant is opposite of 7th house cusp (180° offset)', () {
      final calc = HouseCalculator();
      final dt = DateTime.utc(1985, 3, 15, 8, 30);
      final loc = const GeoLocation(
        latitude: 51.5,
        longitude: -0.12,
        cityName: 'london',
        countryCode: 'gb',
        timezone: 'Europe/London',
      );
      final cusps = calc.calculateCusps(dt, loc);
      final asc = cusps[0];
      final desc = cusps[6];
      var offset = (desc - asc) % 360;
      if (offset < 0) offset += 360;
      expect(offset, closeTo(180, 0.5),
          reason: 'ASC ${asc.toStringAsFixed(2)}° '
              'vs 7th cusp ${desc.toStringAsFixed(2)}°, '
              'offset ${offset.toStringAsFixed(2)}° (must be 180°)');
    });
  });

  group('Aspect detector — correctness and symmetry', () {
    final det = AspectDetector();
    test('90° separation detects as square', () {
      final aspect = det.detectAspect(0, 90, 8);
      expect(aspect?.type, equals(AspectType.square));
    });
    test('120° detects as trine', () {
      final aspect = det.detectAspect(0, 120, 8);
      expect(aspect?.type, equals(AspectType.trine));
    });
    test('180° detects as opposition', () {
      final aspect = det.detectAspect(0, 180, 8);
      expect(aspect?.type, equals(AspectType.opposition));
    });
    test('detection is angle-symmetric (A/B == B/A)', () {
      final ab = det.detectAspect(45, 135, 8);
      final ba = det.detectAspect(135, 45, 8);
      expect(ab?.type, equals(ba?.type));
      expect(ab?.orb, closeTo(ba!.orb, 0.001));
    });
    test('detection wraps at 360° boundary', () {
      // 359° and 1° are 2° apart — should detect conjunction.
      final ab = det.detectAspect(359, 1, 8);
      expect(ab?.type, equals(AspectType.conjunction));
      expect(ab?.orb, closeTo(2, 0.001));
    });
  });

  group('Diagnostic summary — absolute errors at reference dates', () {
    test('print deltas for 2024-01-01 (visible in test output)', () {
      final dt = DateTime.utc(2024, 1, 1, 0, 0, 0);
      final report = StringBuffer('\n--- Ephemeris delta report, $dt ---\n');
      var maxDelta = 0.0;
      _jan2024.forEach((planet, expected) {
        final actual = planetLongitude(planet, dt);
        final delta = _angularDelta(actual, expected);
        maxDelta = max(maxDelta, delta);
        report.writeln('  ${planet.name.padRight(10)} '
            'expected=${expected.toStringAsFixed(2).padLeft(7)} '
            'actual=${actual.toStringAsFixed(2).padLeft(7)} '
            'delta=${delta.toStringAsFixed(2).padLeft(6)}° '
            '${delta > _tolerance(planet) ? "✗" : "✓"}');
      });
      report.writeln('max delta: ${maxDelta.toStringAsFixed(2)}°');
      // Always print, never fail — this is diagnostic.
      // ignore: avoid_print
      print(report.toString());
    });
  });
}
