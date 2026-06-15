// ---------------------------------------------------------------------------
// Astronomy constants
//
// Deliberately tiny. Aspect angles live on AspectType.angle, per-planet orbs
// on Planet.defaultOrb, significance on Planet.significanceRank — those enums
// are the canonical homes. Don't re-add parallel copies here.
// ---------------------------------------------------------------------------
abstract final class AstronomyConfig {
  /// Ternary search iterations for peak time calculation. 30 keeps Pluto's
  /// 5-year search window converging to ~minute precision; lower counts left
  /// outer planets on the order of hours/days, which surfaced as the "every
  /// seasonal transit shows ±6 days" bug.
  static const int peakSearchIterations = 30;
}
