import 'package:test/test.dart';
import 'package:yomi_ephemeris/astronomy/transit_finder.dart';
import 'package:yomi_ephemeris/models/birth_chart.dart';
import 'package:yomi_ephemeris/models/planet.dart';
import 'package:yomi_ephemeris/models/geo_location.dart';

/// Creates a test birth chart with known planet positions.
/// These positions are for a hypothetical birth chart — not a real person.
/// The goal is to have predictable aspect geometry for testing.
BirthChart _makeTestChart() {
  return BirthChart(
    id: 'test-chart',
    planetPositions: {
      Planet.sun: 15.0, // 15° Aries
      Planet.moon: 100.0, // 10° Cancer
      Planet.mercury: 25.0, // 25° Aries
      Planet.venus: 45.0, // 15° Taurus
      Planet.mars: 200.0, // 20° Libra
      Planet.jupiter: 120.0, // 0° Leo
      Planet.saturn: 280.0, // 10° Capricorn
      Planet.uranus: 310.0, // 10° Aquarius
      Planet.neptune: 340.0, // 10° Pisces
      Planet.pluto: 270.0, // 0° Capricorn
      Planet.northNode: 60.0, // 0° Gemini
      Planet.chiron: 90.0, // 0° Cancer
    },
    houseCusps: [
      0.0, 30.0, 60.0, 90.0, 120.0, 150.0,
      180.0, 210.0, 240.0, 270.0, 300.0, 330.0,
    ],
    birthDateTime: DateTime.utc(1990, 6, 15, 14, 30, 0),
    birthLocation: const GeoLocation(
      latitude: 40.7128,
      longitude: -74.006,
      cityName: 'New York',
      countryCode: 'US',
      timezone: 'America/New_York',
    ),
    calculatedAt: DateTime.utc(2024, 1, 1),
  );
}

void main() {
  late TransitFinder finder;

  setUp(() {
    finder = TransitFinder();
  });

  group('findActiveTransits', () {
    test('returns non-empty list for a typical chart and date', () {
      final chart = _makeTestChart();
      final now = DateTime.utc(2024, 6, 15, 12, 0, 0);
      final transits = finder.findActiveTransits(chart, now);

      // There should be at least some active transits
      expect(transits, isNotEmpty);
    });

    test('all transits have valid fields', () {
      final chart = _makeTestChart();
      final now = DateTime.utc(2024, 6, 15, 12, 0, 0);
      final transits = finder.findActiveTransits(chart, now);

      for (final transit in transits) {
        // ID should be a non-empty string
        expect(transit.id, isNotEmpty);
        // Orb should be non-negative
        expect(transit.orb, greaterThanOrEqualTo(0));
        // Longitudes should be in valid range
        expect(transit.transitingLongitude, greaterThanOrEqualTo(0));
        expect(transit.transitingLongitude, lessThan(360));
        expect(transit.natalLongitude, greaterThanOrEqualTo(0));
        expect(transit.natalLongitude, lessThan(360));
        // Peak time should exist
        expect(transit.peakTime, isNotNull);
        // Window should be ordered
        expect(
          transit.windowEnd.isAfter(transit.windowStart),
          isTrue,
          reason: 'windowEnd should be after windowStart for ${transit.id}',
        );
        // Peak must fall inside the active window. Outer planets that
        // retrograde back into orb of a prior direct pass used to return a
        // peakTime from the OLD pass while the windowStart/windowEnd
        // bracketed the CURRENT retrograde window — and the timeline UI
        // rendered the peak label outside its axis. Locked in via
        // commit 07c823a's `earliest`/`latest` clamp on `_findPeakTime`.
        expect(
          !transit.peakTime.isBefore(transit.windowStart) &&
              !transit.peakTime.isAfter(transit.windowEnd),
          isTrue,
          reason: 'peakTime ${transit.peakTime} must fall within '
              '[${transit.windowStart}, ${transit.windowEnd}] for ${transit.id}',
        );
      }
    });

    test('sorted by orb (tightest first)', () {
      final chart = _makeTestChart();
      final now = DateTime.utc(2024, 6, 15, 12, 0, 0);
      final transits = finder.findActiveTransits(chart, now);

      if (transits.length > 1) {
        for (var i = 1; i < transits.length; i++) {
          // Allow equal orbs (tie-broken by significance)
          expect(
            transits[i].orb,
            greaterThanOrEqualTo(transits[i - 1].orb),
            reason: 'Transit at index $i should have orb >= transit at index ${i - 1}',
          );
        }
      }
    });

    test('no same-planet transits', () {
      final chart = _makeTestChart();
      final now = DateTime.utc(2024, 6, 15, 12, 0, 0);
      final transits = finder.findActiveTransits(chart, now);

      for (final transit in transits) {
        expect(
          transit.transitingPlanet != transit.natalPlanet,
          isTrue,
          reason:
              '${transit.transitingPlanet.name} should not transit itself',
        );
      }
    });

    test('transit IDs are deterministic (same inputs = same IDs)', () {
      final chart = _makeTestChart();
      final now = DateTime.utc(2024, 6, 15, 12, 0, 0);

      final transits1 = finder.findActiveTransits(chart, now);
      final transits2 = finder.findActiveTransits(chart, now);

      expect(transits1.length, equals(transits2.length));
      for (var i = 0; i < transits1.length; i++) {
        expect(
          transits1[i].id,
          equals(transits2[i].id),
          reason: 'Transit IDs should be stable across calls',
        );
      }
    });

    test('aspect types are geometrically valid', () {
      final chart = _makeTestChart();
      final now = DateTime.utc(2024, 6, 15, 12, 0, 0);
      final transits = finder.findActiveTransits(chart, now);

      for (final transit in transits) {
        // Calculate the actual angular separation
        var sep = (transit.transitingLongitude - transit.natalLongitude).abs();
        if (sep > 180) sep = 360 - sep;

        // The separation should be within orb of the declared aspect angle
        final expectedAngle = transit.aspectType.angle;
        final diff = (sep - expectedAngle).abs();
        expect(
          diff,
          lessThanOrEqualTo(transit.orb + 0.1), // small float tolerance
          reason:
              '${transit.transitingPlanet.name} ${transit.aspectType.name} '
              '${transit.natalPlanet.name}: separation $sep should be within '
              'orb ${transit.orb} of aspect angle $expectedAngle',
        );
      }
    });
  });
}
