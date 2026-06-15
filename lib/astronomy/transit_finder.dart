import '../models/birth_chart.dart';
import '../models/house.dart';
import '../models/planet.dart';
import '../models/transit.dart';
import '../astronomy_config.dart';
import 'aspect_detector.dart';
import 'planet_position.dart';

/// Combined orb tolerance for a transit pair: the average of each planet's
/// default orb. Top-level so tools (e.g., the bespoke-bank enumerator)
/// share the exact value the runtime uses for orb detection.
double combinedOrb(Planet transiting, Planet natal) =>
    (transiting.defaultOrb + natal.defaultOrb) / 2;

/// Finds all active transits against a birth chart at the current moment.
class TransitFinder {
  final AspectDetector _detector = AspectDetector();

  /// Calculate all active transits for [chart] at [now].
  ///
  /// Returns transits sorted by orb (tightest first), with ties broken
  /// by planet significance (Pluto > Neptune > ... > Moon).
  List<Transit> findActiveTransits(BirthChart chart, DateTime now) {
    final currentPositions = allPlanetPositions(now);
    final transits = <Transit>[];

    for (final transitingPlanet in Planet.values) {
      final transitLon = currentPositions[transitingPlanet]!;

      for (final natalPlanet in Planet.values) {
        // Skip same-planet aspects for faster planets (Moon transiting Moon)
        // as they're not traditionally meaningful.
        if (transitingPlanet == natalPlanet) continue;

        final natalLon = chart.planetPositions[natalPlanet]!;
        final orbTolerance = _combinedOrb(transitingPlanet, natalPlanet);

        final match = _detector.detectAspect(transitLon, natalLon, orbTolerance);
        if (match == null) continue;

        final direction = _detector.getDirection(
          transitingPlanet,
          natalPlanet,
          natalLon,
          now,
        );

        final house = House.fromLongitude(transitLon, chart.houseCusps);

        // Compute the active orb window first, then constrain the peak
        // search inside it. Without the constraint, outer planets that go
        // through retrograde re-crosses can return a `peakTime` from a
        // PRIOR direct pass while the user is in the CURRENT retrograde
        // window — and the timeline slider then renders the peak label
        // outside the window axis, which looks like a bug to the user.
        // Bounding the search to the window guarantees peak ∈ [start, end].
        final window = _transitWindow(
          transitingPlanet,
          natalLon,
          match.type.angle,
          orbTolerance,
          now,
        );
        final peakTime = _findPeakTime(
          transitingPlanet,
          natalLon,
          match.type.angle,
          now,
          earliest: window.start,
          latest: window.end,
        );

        transits.add(Transit(
          id: '${transitingPlanet.name}_${natalPlanet.name}_${match.type.name}',
          transitingPlanet: transitingPlanet,
          natalPlanet: natalPlanet,
          aspectType: match.type,
          orb: match.orb,
          direction: direction,
          house: house,
          peakTime: peakTime,
          windowStart: window.start,
          windowEnd: window.end,
          transitingLongitude: transitLon,
          natalLongitude: natalLon,
          isRetrograde: isPlanetRetrograde(transitingPlanet, now),
        ));
      }
    }

    // Sort: tightest orb first, break ties by significance (higher = first).
    transits.sort((a, b) {
      final orbCmp = a.orb.compareTo(b.orb);
      if (orbCmp != 0) return orbCmp;
      return b.transitingPlanet.significanceRank
          .compareTo(a.transitingPlanet.significanceRank);
    });

    return transits;
  }

  /// Combined orb: average of the two planets' default orbs.
  double _combinedOrb(Planet transiting, Planet natal) =>
      combinedOrb(transiting, natal);

  /// Find peak time (minimum orb) using ternary search. Search window scales
  /// with planet speed — outer planets' exact-aspect dates can be months or
  /// years away from "now," so a fixed ±7-day window pinned every slow-planet
  /// peak to the window boundary (visible bug: every "this season" entry
  /// rendered as ~6 days from now).
  ///
  /// [earliest] and [latest] clamp the search to a known orb window so the
  /// returned peak always falls inside it. Without clamping, a retrograde
  /// re-cross window can hold the user while the global minimum-orb date
  /// sits a year earlier on a prior direct pass, breaking the timeline UI.
  DateTime _findPeakTime(
    Planet planet,
    double natalLon,
    double aspectAngle,
    DateTime now, {
    DateTime? earliest,
    DateTime? latest,
  }) {
    final span = _peakSearchSpan(planet);
    var left = now.subtract(span);
    var right = now.add(span);
    if (earliest != null && left.isBefore(earliest)) left = earliest;
    if (latest != null && right.isAfter(latest)) right = latest;

    final iterations = AstronomyConfig.peakSearchIterations;
    for (var i = 0; i < iterations; i++) {
      final third = right.difference(left) ~/ 3;
      final m1 = left.add(third);
      final m2 = right.subtract(third);

      final orb1 = _orbAt(planet, natalLon, aspectAngle, m1);
      final orb2 = _orbAt(planet, natalLon, aspectAngle, m2);

      if (orb1 < orb2) {
        right = m2;
      } else {
        left = m1;
      }
    }

    return left.add(right.difference(left) ~/ 2);
  }

  /// Half-window (±) for the peak search. Mirrors the per-planet caps used
  /// in [_maxWindowSpan] but tuned for "find the exact-aspect date" rather
  /// than "find when the orb tolerance crosses." Outer planets need years.
  Duration _peakSearchSpan(Planet planet) {
    return switch (planet) {
      Planet.moon => const Duration(hours: 48),
      Planet.sun => const Duration(days: 10),
      Planet.mercury => const Duration(days: 14),
      Planet.venus => const Duration(days: 21),
      Planet.mars => const Duration(days: 60),
      Planet.jupiter => const Duration(days: 120),
      Planet.saturn => const Duration(days: 365),
      Planet.uranus || Planet.chiron => const Duration(days: 365 * 2),
      Planet.neptune => const Duration(days: 365 * 3),
      Planet.pluto => const Duration(days: 365 * 5),
      Planet.northNode => const Duration(days: 180),
    };
  }

  /// Calculate the orb for a specific aspect at a given time.
  double _orbAt(Planet planet, double natalLon, double aspectAngle, DateTime t) {
    final lon = planetLongitude(planet, t);
    var sep = (lon - natalLon).abs();
    if (sep > 180) sep = 360 - sep;
    return (sep - aspectAngle).abs();
  }

  /// Estimate the transit window (when orb enters/exits tolerance).
  ///
  /// Exponential search to bracket a point outside the orb, then bisection
  /// to pin down the boundary. Much faster than a linear walk, and — more
  /// importantly — actually correct for slow planets whose transits can
  /// span months or years. The old 30-day cap with a fixed 6-hour step
  /// capped every outer-planet window wrong and still took thousands of
  /// iterations to get there.
  ({DateTime start, DateTime end}) _transitWindow(
    Planet planet,
    double natalLon,
    double aspectAngle,
    double orbTolerance,
    DateTime now,
  ) {
    return (
      start: _findBoundary(
        planet, natalLon, aspectAngle, orbTolerance, now,
        forward: false,
      ),
      end: _findBoundary(
        planet, natalLon, aspectAngle, orbTolerance, now,
        forward: true,
      ),
    );
  }

  /// Walk outward from [now] (which is inside the orb) until we find a
  /// sample outside the orb, then bisect to pin down the crossing.
  DateTime _findBoundary(
    Planet planet,
    double natalLon,
    double aspectAngle,
    double orbTolerance,
    DateTime now, {
    required bool forward,
  }) {
    final maxSpan = _maxWindowSpan(planet);
    var step = _initialStep(planet);

    DateTime shift(DateTime t, Duration by) =>
        forward ? t.add(by) : t.subtract(by);

    // Exponential search for a point outside the orb.
    var outside = shift(now, step);
    final hardCap = shift(now, maxSpan);
    while (_orbAt(planet, natalLon, aspectAngle, outside) < orbTolerance) {
      step *= 2;
      final next = shift(outside, step);
      // If we've walked past the planet-specific cap, stop here —
      // the transit is longer than we're willing to represent.
      final capExceeded = forward
          ? next.isAfter(hardCap)
          : next.isBefore(hardCap);
      if (capExceeded) return hardCap;
      outside = next;
    }

    // Bisect between `now` (inside) and `outside` (outside).
    var inside = now;
    for (var i = 0; i < 24; i++) {
      final midMicros =
          (inside.microsecondsSinceEpoch + outside.microsecondsSinceEpoch) ~/ 2;
      final mid = DateTime.fromMicrosecondsSinceEpoch(
        midMicros,
        isUtc: now.isUtc,
      );
      if (_orbAt(planet, natalLon, aspectAngle, mid) < orbTolerance) {
        inside = mid;
      } else {
        outside = mid;
      }
    }
    return inside;
  }

  /// Hard cap on how far we'll search for a window boundary in one direction.
  /// Outer planets can hold an orb via retrograde stations for years; the cap
  /// is generous but finite.
  Duration _maxWindowSpan(Planet planet) {
    return switch (planet) {
      Planet.moon => const Duration(days: 3),
      Planet.mercury => const Duration(days: 30),
      Planet.venus => const Duration(days: 60),
      Planet.sun => const Duration(days: 10),
      Planet.mars => const Duration(days: 180),
      Planet.jupiter => const Duration(days: 365),
      Planet.saturn => const Duration(days: 365 * 3),
      Planet.uranus || Planet.chiron => const Duration(days: 365 * 5),
      Planet.neptune => const Duration(days: 365 * 7),
      Planet.pluto => const Duration(days: 365 * 10),
      Planet.northNode => const Duration(days: 180),
    };
  }

  /// Starting step for the exponential search. Doubles on each miss,
  /// so this mostly affects the first probe's precision.
  Duration _initialStep(Planet planet) {
    return switch (planet) {
      Planet.moon => const Duration(minutes: 20),
      Planet.mercury || Planet.venus || Planet.sun =>
        const Duration(hours: 6),
      Planet.mars => const Duration(hours: 12),
      Planet.jupiter => const Duration(days: 1),
      Planet.saturn || Planet.northNode => const Duration(days: 3),
      Planet.uranus || Planet.chiron => const Duration(days: 5),
      Planet.neptune || Planet.pluto => const Duration(days: 7),
    };
  }
}
