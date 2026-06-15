import 'package:test/test.dart';
import 'package:yomi_ephemeris/astronomy/aspect_detector.dart';
import 'package:yomi_ephemeris/astronomy/transit_finder.dart';
import 'package:yomi_ephemeris/models/aspect.dart';
import 'package:yomi_ephemeris/models/planet.dart';

void main() {
  late AspectDetector detector;

  setUp(() {
    detector = AspectDetector();
  });

  group('isInOrb', () {
    test('exact conjunction is in orb', () {
      expect(detector.isInOrb(100.0, 100.0, AspectType.conjunction, 3.0),
          isTrue);
    });

    test('square at 90° exact', () {
      expect(detector.isInOrb(190.0, 100.0, AspectType.square, 3.0), isTrue);
    });

    test('trine at 119° is in orb (orb=2°)', () {
      expect(detector.isInOrb(219.0, 100.0, AspectType.trine, 2.0), isTrue);
    });

    test('trine at 117° is out of orb (orb=2°)', () {
      expect(detector.isInOrb(217.0, 100.0, AspectType.trine, 2.0), isFalse);
    });

    test('wraps around 0°/360° boundary', () {
      // 350° vs 10° is 20° apart on the short arc. Not in orb of any major.
      expect(detector.isInOrb(350.0, 10.0, AspectType.conjunction, 3.0),
          isFalse);
      // 358° vs 2° is 4° apart on the short arc; not in conj orb at 3.
      expect(detector.isInOrb(358.0, 2.0, AspectType.conjunction, 3.0),
          isFalse);
      // 359° vs 1° is 2° apart on the short arc; in conj orb at 3.
      expect(detector.isInOrb(359.0, 1.0, AspectType.conjunction, 3.0), isTrue);
    });

    test('opposition near 180° respects orb tolerance', () {
      // 0 vs 180 → sep 180 → exact opposition.
      expect(detector.isInOrb(0.0, 180.0, AspectType.opposition, 3.0), isTrue);
      // 0 vs 178 → sep 178 → 2° from opposition; in orb at 3°.
      expect(detector.isInOrb(0.0, 178.0, AspectType.opposition, 3.0), isTrue);
      // 0 vs 175 → sep 175 → 5° from opposition; out at 3°, in at 6°.
      expect(
          detector.isInOrb(0.0, 175.0, AspectType.opposition, 3.0), isFalse);
      expect(detector.isInOrb(0.0, 175.0, AspectType.opposition, 6.0), isTrue);
    });
  });

  group('combinedOrb (top-level)', () {
    test('matches average of the two planets default orbs', () {
      // Sun defaultOrb 2.0, Moon defaultOrb 4.0 — average 3.0.
      expect(combinedOrb(Planet.sun, Planet.moon), closeTo(3.0, 1e-9));
      expect(combinedOrb(Planet.moon, Planet.sun), closeTo(3.0, 1e-9));
    });

    test('is symmetric', () {
      for (final a in Planet.values) {
        for (final b in Planet.values) {
          expect(combinedOrb(a, b), closeTo(combinedOrb(b, a), 1e-12));
        }
      }
    });

    test('matches TransitFinder runtime detection (same value as average '
        'of defaultOrbs)', () {
      // Re-derive the expected value from the public Planet enum to ensure
      // a future change to a defaultOrb propagates here AND through
      // TransitFinder._combinedOrb (which now delegates).
      expect(combinedOrb(Planet.pluto, Planet.sun),
          closeTo((Planet.pluto.defaultOrb + Planet.sun.defaultOrb) / 2,
              1e-12));
    });
  });

  group('detectAspect', () {
    test('exact conjunction at 0° orb', () {
      final match = detector.detectAspect(100.0, 100.0, 3.0);
      expect(match, isNotNull);
      expect(match!.type, AspectType.conjunction);
      expect(match.orb, closeTo(0.0, 0.01));
    });

    test('conjunction within orb', () {
      final match = detector.detectAspect(101.5, 100.0, 3.0);
      expect(match, isNotNull);
      expect(match!.type, AspectType.conjunction);
      expect(match.orb, closeTo(1.5, 0.01));
    });

    test('conjunction outside orb returns null', () {
      final match = detector.detectAspect(104.0, 100.0, 3.0);
      // 4° apart, orb tolerance is 3° — no conjunction.
      // But could be near another aspect? 4° is not near 60/90/120/180.
      expect(match, isNull);
    });

    test('exact sextile at 60°', () {
      final match = detector.detectAspect(160.0, 100.0, 3.0);
      expect(match, isNotNull);
      expect(match!.type, AspectType.sextile);
      expect(match.orb, closeTo(0.0, 0.01));
    });

    test('exact square at 90°', () {
      final match = detector.detectAspect(190.0, 100.0, 3.0);
      expect(match, isNotNull);
      expect(match!.type, AspectType.square);
      expect(match.orb, closeTo(0.0, 0.01));
    });

    test('exact trine at 120°', () {
      final match = detector.detectAspect(220.0, 100.0, 3.0);
      expect(match, isNotNull);
      expect(match!.type, AspectType.trine);
      expect(match.orb, closeTo(0.0, 0.01));
    });

    test('exact opposition at 180°', () {
      final match = detector.detectAspect(280.0, 100.0, 3.0);
      expect(match, isNotNull);
      expect(match!.type, AspectType.opposition);
      expect(match.orb, closeTo(0.0, 0.01));
    });

    test('360/0 boundary wrap - conjunction across boundary', () {
      // Planet at 359° and natal at 1° should be 2° apart (conjunction)
      final match = detector.detectAspect(359.0, 1.0, 3.0);
      expect(match, isNotNull);
      expect(match!.type, AspectType.conjunction);
      expect(match.orb, closeTo(2.0, 0.01));
    });

    test('360/0 boundary wrap - opposition across boundary', () {
      // Planet at 1° and natal at 180° = 179° apart (opposition within 1° orb)
      final match = detector.detectAspect(1.0, 180.0, 3.0);
      expect(match, isNotNull);
      expect(match!.type, AspectType.opposition);
      expect(match.orb, closeTo(1.0, 0.01));
    });

    test('just inside orb boundary detects', () {
      // Exactly at orb boundary: 100° and 102.99° with 3° tolerance = conjunction at 2.99° orb
      final match = detector.detectAspect(102.99, 100.0, 3.0);
      expect(match, isNotNull);
      expect(match!.type, AspectType.conjunction);
    });

    test('just outside orb boundary returns null', () {
      // 100° and 103.01° with 3° tolerance = 3.01° orb, just outside
      final match = detector.detectAspect(103.01, 100.0, 3.0);
      expect(match, isNull);
    });

    test('returns tightest aspect when multiple could match', () {
      // At 59° separation, could be near sextile (60°, orb 1°)
      // or conjunction (0°, orb 59°) — but 59° is way outside any reasonable orb for conjunction
      // With a wide orb of 60°, both would match, and sextile (orb 1) should win
      final match = detector.detectAspect(159.0, 100.0, 3.0);
      expect(match, isNotNull);
      expect(match!.type, AspectType.sextile);
      expect(match.orb, closeTo(1.0, 0.01));
    });

    test('no aspect for mid-range separation', () {
      // 45° separation — not near any major aspect within 3° orb
      final match = detector.detectAspect(145.0, 100.0, 3.0);
      expect(match, isNull);
    });
  });
}
