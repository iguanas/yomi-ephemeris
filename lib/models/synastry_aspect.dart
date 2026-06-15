import 'aspect.dart';
import 'planet.dart';

/// One cross-chart aspect between a user's planet and a partner's planet.
///
/// Ordered: `userPlanet` is always the user's, `partnerPlanet` the partner's.
/// Direction agnostic (not transit-based) — synastry compares two static
/// natal charts, so there's no "applying vs separating".
class SynastryAspect {
  const SynastryAspect({
    required this.userPlanet,
    required this.partnerPlanet,
    required this.aspectType,
    required this.orb,
  });

  final Planet userPlanet;
  final Planet partnerPlanet;
  final AspectType aspectType;
  final double orb;

  /// Lower orb = tighter = more psychologically "loud". Used for ranking.
  double get tightness => orb;

  /// Rough "importance" score for sorting — prefers tight orbs AND important
  /// planets. Sun/Moon/Venus/Mars in a synastry chart outweigh Mercury or
  /// outer planet aspects for relational significance.
  double get significanceScore {
    // Base: tighter orbs score higher (invert orb into 0-1 range).
    final tightnessScore = 1.0 - (orb / 10).clamp(0.0, 1.0);
    // Relational planets on either side get a bonus.
    final relWeight = _relationalWeight(userPlanet) +
        _relationalWeight(partnerPlanet);
    return tightnessScore * 10 + relWeight;
  }

  static double _relationalWeight(Planet p) => switch (p) {
        Planet.sun => 3.0,
        Planet.moon => 3.0,
        Planet.venus => 3.5,
        Planet.mars => 3.0,
        Planet.mercury => 1.5,
        Planet.jupiter => 1.5,
        Planet.saturn => 2.0,
        Planet.uranus || Planet.neptune || Planet.pluto => 1.0,
        _ => 0.5,
      };
}
