import '../models/aspect.dart';
import '../models/planet.dart';
import 'planet_position.dart';

/// Detects aspects between two ecliptic longitudes and determines direction.
class AspectDetector {
  /// Check if two longitudes form any of the 5 major aspects within orb.
  /// Returns the tightest match, or null if no aspect is active. Minor
  /// aspects (quincunx, semisextile, etc.) are deliberately not detected
  /// — see `lib/models/aspect.dart` for the decision rationale.
  AspectMatch? detectAspect(
    double longitude1,
    double longitude2,
    double orbTolerance,
  ) {
    final separation = _angularSeparation(longitude1, longitude2);
    AspectMatch? best;

    for (final type in AspectType.values) {
      final orb = (separation - type.angle).abs();
      if (orb <= orbTolerance) {
        if (best == null || orb < best.orb) {
          best = AspectMatch(type: type, orb: orb);
        }
      }
    }
    return best;
  }

  /// Whether two longitudes are within [orbTolerance] of the specified
  /// [aspect]'s exact angle. Used by tools that need a per-aspect orb check
  /// (enumeration / sweep tools) where [detectAspect]'s "closest tightest
  /// match" semantics are the wrong question. Shares the same angular-
  /// separation logic so the answer cannot drift from runtime detection.
  bool isInOrb(
    double longitude1,
    double longitude2,
    AspectType aspect,
    double orbTolerance,
  ) {
    final separation = _angularSeparation(longitude1, longitude2);
    return (separation - aspect.angle).abs() <= orbTolerance;
  }

  /// Determine if the aspect is applying (getting tighter) or separating.
  ///
  /// Lookback scales with planet speed: fast movers get a 1-hour lookback,
  /// outer planets need days to produce a measurable orb delta above the
  /// ephemeris's ~0.001° computation noise. Without this scaling, Saturn/
  /// Pluto transits always read as "exact."
  AspectDirection getDirection(
    Planet transitingPlanet,
    Planet natalPlanet,
    double natalLongitude,
    DateTime now,
  ) {
    final lookback = _directionLookback(transitingPlanet);

    final currentLon = planetLongitude(transitingPlanet, now);
    final pastLon = planetLongitude(
      transitingPlanet,
      now.subtract(lookback),
    );

    final currentSep = _angularSeparation(currentLon, natalLongitude);
    final pastSep = _angularSeparation(pastLon, natalLongitude);

    // Find which aspect we're near
    double? closestAspectAngle;
    double minDiff = 360;
    for (final type in AspectType.values) {
      final diff = (currentSep - type.angle).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestAspectAngle = type.angle;
      }
    }

    final currentOrb = (currentSep - closestAspectAngle!).abs();
    final pastOrb = (pastSep - closestAspectAngle).abs();
    final delta = pastOrb - currentOrb; // positive => orb shrank => applying

    // Exact when motion over the lookback is <5% of the typical expected
    // orb delta for this planet's speed — i.e., around a retrograde station
    // or the instant of peak.
    final expected = _expectedOrbDelta(transitingPlanet, lookback);
    if (delta.abs() < expected * 0.05) return AspectDirection.exact;

    return delta > 0
        ? AspectDirection.applying
        : AspectDirection.separating;
  }

  /// How far back to look when comparing orbs. Scales inversely with
  /// planetary speed — needs to be long enough that `delta` sits well
  /// above the ephemeris's numerical noise floor.
  Duration _directionLookback(Planet planet) {
    return switch (planet) {
      Planet.moon => const Duration(hours: 1),
      Planet.mercury || Planet.venus || Planet.sun =>
        const Duration(hours: 6),
      Planet.mars => const Duration(hours: 24),
      Planet.jupiter => const Duration(hours: 48),
      Planet.saturn => const Duration(days: 3),
      Planet.uranus || Planet.chiron => const Duration(days: 5),
      Planet.neptune || Planet.pluto || Planet.northNode =>
        const Duration(days: 7),
    };
  }

  /// Approximate |Δorb| over [lookback] for [planet] based on mean daily
  /// motion. Used to set the exact-threshold proportional to expected
  /// signal, not a fixed epsilon.
  double _expectedOrbDelta(Planet planet, Duration lookback) {
    final dailyDeg = switch (planet) {
      Planet.moon => 13.2,
      Planet.mercury => 1.4,
      Planet.venus => 1.2,
      Planet.sun => 1.0,
      Planet.mars => 0.5,
      Planet.jupiter => 0.083,
      Planet.saturn => 0.033,
      Planet.uranus => 0.012,
      Planet.neptune => 0.006,
      Planet.pluto => 0.004,
      Planet.northNode => 0.053, // ~19.4°/year mean motion (regressive)
      Planet.chiron => 0.019,
    };
    final days = lookback.inMinutes / (24 * 60);
    return dailyDeg * days;
  }

  /// Angular separation between two longitudes, handling 0°/360° wrap.
  /// Always returns 0–180°.
  double _angularSeparation(double lon1, double lon2) {
    var diff = (lon1 - lon2).abs();
    if (diff > 180) diff = 360 - diff;
    return diff;
  }
}

/// Result of aspect detection.
class AspectMatch {
  const AspectMatch({required this.type, required this.orb});

  final AspectType type;
  final double orb;
}
