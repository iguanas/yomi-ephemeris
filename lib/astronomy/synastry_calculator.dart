import '../models/birth_chart.dart';
import '../models/planet.dart';
import '../models/synastry_aspect.dart';
import 'aspect_detector.dart';

/// Cross-chart aspect calculation. Given two natal charts (user + partner),
/// returns every aspect formed between a planet in chart A and a planet in
/// chart B, within the configured orb.
///
/// Symmetry note: when aspects are computed for pairs (A.sun, B.moon), the
/// pair (B.moon, A.sun) describes the same geometric fact. We only emit one.
class SynastryCalculator {
  SynastryCalculator({AspectDetector? detector, this.orbTolerance = 6.0})
      : _detector = detector ?? AspectDetector();

  final AspectDetector _detector;

  /// Max orb in degrees. 6° is tighter than typical natal-chart tolerances
  /// (which go to 8–10°) because synastry is about what's *loud*, not
  /// exhaustive.
  final double orbTolerance;

  /// Planets included in synastry. North Node and Chiron are excluded —
  /// they're interesting but add noise for v1.
  static const _syntastryPlanets = [
    Planet.sun,
    Planet.moon,
    Planet.mercury,
    Planet.venus,
    Planet.mars,
    Planet.jupiter,
    Planet.saturn,
    Planet.uranus,
    Planet.neptune,
    Planet.pluto,
  ];

  List<SynastryAspect> compute(BirthChart user, BirthChart partner) {
    final out = <SynastryAspect>[];
    for (final up in _syntastryPlanets) {
      final uLon = user.planetPositions[up];
      if (uLon == null) continue;
      for (final pp in _syntastryPlanets) {
        final pLon = partner.planetPositions[pp];
        if (pLon == null) continue;
        final match = _detector.detectAspect(uLon, pLon, orbTolerance);
        if (match == null) continue;
        out.add(SynastryAspect(
          userPlanet: up,
          partnerPlanet: pp,
          aspectType: match.type,
          orb: match.orb,
        ));
      }
    }
    // Rank by significance so the top of the list is what people actually
    // want to see first.
    out.sort((a, b) => b.significanceScore.compareTo(a.significanceScore));
    return out;
  }
}
