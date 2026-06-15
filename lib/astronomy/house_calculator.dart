import 'dart:math';
import '../models/geo_location.dart';
import 'planet_position.dart';

const _deg2rad = pi / 180;
const _rad2deg = 180 / pi;

/// Calculates the 12 house cusps for a given birth time and location.
///
/// Default house system is Placidus (what Co-Star, astro.com, and most
/// Western professional astrology software use). At extreme latitudes
/// (|φ| > 66°) the Placidus formula stops converging cleanly — the Sun
/// can stay above or below the horizon all day, so "semi-diurnal arc"
/// isn't well-defined. We fall back to Porphyry in that window, and to
/// Equal House only when Porphyry itself would be useless (very close
/// to the pole).
class HouseCalculator {
  /// Returns a list of 12 house cusp longitudes (0-360°).
  /// Index 0 = 1st house (Ascendant), index 9 = 10th house (Midheaven).
  List<double> calculateCusps(DateTime birthDateTime, GeoLocation location) {
    final t = julianCenturies(birthDateTime);
    final lst = _localSiderealTime(birthDateTime, location.longitude);
    final obliquity = _meanObliquity(t);

    final mc = _midheaven(lst, obliquity);
    final asc = _ascendant(lst, obliquity, location.latitude);

    // Near the pole: circumpolar points break the SA formula. Equal
    // House is the honest fallback.
    if (location.latitude.abs() >= 85) {
      return _equalHouseCusps(asc);
    }

    // High latitudes (above the Arctic Circle): Placidus becomes
    // degenerate because the semi-diurnal arc goes to 0 or π. Use
    // Porphyry.
    if (location.latitude.abs() > 66) {
      return _porphyryCusps(asc, mc);
    }

    final placidus =
        _placidusCusps(lst, obliquity, location.latitude, asc, mc);
    // Iteration failed to converge (rare, usually at latitudes near 66°).
    // Fall back to Porphyry so we never ship NaN cusps.
    if (placidus == null) {
      return _porphyryCusps(asc, mc);
    }
    return placidus;
  }

  /// Ascendant (1st house cusp) — the rising degree.
  double ascendant(DateTime birthDateTime, GeoLocation location) {
    final t = julianCenturies(birthDateTime);
    final lst = _localSiderealTime(birthDateTime, location.longitude);
    final obliquity = _meanObliquity(t);
    return _ascendant(lst, obliquity, location.latitude);
  }
}

// ─── Internal calculations ────────────────────────────────────────────────

/// Greenwich Mean Sidereal Time in degrees.
double _gmst(DateTime dt) {
  final jd = julianDayNumber(dt);
  final t = (jd - 2451545.0) / 36525.0;
  var gmst = 280.46061837 +
      360.98564736629 * (jd - 2451545.0) +
      0.000387933 * t * t -
      t * t * t / 38710000.0;
  return gmst % 360;
}

/// Local Sidereal Time in degrees.
double _localSiderealTime(DateTime dt, double longitude) {
  return (_gmst(dt) + longitude) % 360;
}

/// Mean obliquity of the ecliptic.
double _meanObliquity(double t) {
  return 23.4393 - 0.0130 * t;
}

/// Midheaven (MC) — convert RAMC to ecliptic longitude.
double _midheaven(double lst, double obliquity) {
  final ramcRad = lst * _deg2rad;
  final oblRad = obliquity * _deg2rad;
  var mc = atan2(sin(ramcRad), cos(ramcRad) * cos(oblRad)) * _rad2deg;
  mc = mc % 360;
  if (mc < 0) mc += 360;
  return mc;
}

/// Ascendant from LST, obliquity, and latitude.
///
/// Formula from Meeus *Astronomical Algorithms* Ch. 13:
///   tan ψ = cos θ / (−sin ε · tan φ − cos ε · sin θ)
/// Previous implementation had both numerator and denominator signs
/// flipped, producing the DESCENDANT (180° off) for every chart.
/// The `atan2` arrangement below gives the ecliptic point currently
/// rising on the east horizon, correctly quadrant-resolved.
double _ascendant(double lst, double obliquity, double latitude) {
  final lstRad = lst * _deg2rad;
  final oblRad = obliquity * _deg2rad;
  final latRad = latitude * _deg2rad;

  var asc = atan2(
    cos(lstRad),
    -sin(latRad) / cos(latRad) * sin(oblRad) - cos(oblRad) * sin(lstRad),
  ) * _rad2deg;

  asc = asc % 360;
  if (asc < 0) asc += 360;
  return asc;
}

/// Equal house cusps — ASC + 30° per house.
///
/// CONVENTION (audit P2-1): in this branch cusps[9] is ASC+270°, NOT the
/// true Midheaven — Equal House measures from the Ascendant and lets the
/// MC float freely, so consumers reading cusps[9] as "the MC" get the
/// nonagesimal instead (measured 84° off the true MC at 86°N). This
/// branch only runs at |lat| ≥ 85° (population ≈ zero), and swapping the
/// real MC into cusps[9] would break the monotonic-cusp invariant that
/// House.fromLongitude and the cusp-ordering tests rely on, so the
/// convention is documented rather than "fixed". If polar charts ever
/// matter, return the true MC alongside the cusps instead of inside them.
List<double> _equalHouseCusps(double asc) {
  return List.generate(12, (i) => (asc + 30.0 * i) % 360);
}

/// Placidus house cusps — the Western astrology default. Divides the
/// diurnal arc of each ecliptic point into three equal *time* intervals
/// and uses those as cusp positions. Only 4 cusps need iterative
/// solving (8, 9, 11, 12) — the other intermediate cusps are their
/// ecliptic opposites ±180°.
///
/// Returns null if any cusp's iteration failed to converge (rare,
/// typically near the Arctic/Antarctic Circles where the semi-arc
/// formula degenerates). Caller falls back to Porphyry.
List<double>? _placidusCusps(
  double lstDeg,
  double obliquityDeg,
  double latitudeDeg,
  double asc,
  double mc,
) {
  final eps = obliquityDeg * _deg2rad;
  final phi = latitudeDeg * _deg2rad;
  final ramc = lstDeg * _deg2rad;
  final cosEps = cos(eps);
  final sinEps = sin(eps);
  final tanPhi = tan(phi);

  /// Iterate for an above-horizon intermediate cusp.
  ///
  /// `sign` is the direction of the cusp's hour angle from the MC:
  ///   -1: east of meridian (HA < 0, ecliptic longitude < MC) — houses
  ///       11 and 12 live here, between MC and ASC.
  ///   +1: west of meridian (HA > 0, ecliptic longitude > MC) — houses
  ///       8 and 9, between MC and DESC.
  ///
  /// `fraction` is the share of the semi-diurnal arc from MC to the
  /// horizon — 1/3 for cusps closer to MC (11, 9), 2/3 for cusps
  /// closer to the horizon (12, 8).
  ///
  /// Target: `α(cusp) = RAMC + sign * fraction * SA(cusp)`. The cusp's
  /// own semi-arc depends on its declination, which depends on its
  /// ecliptic longitude — so iterate.
  double? solve(double fraction, double sign) {
    // Initial guess: treat SA ≈ 90° (as if at the equator).
    var targetAlpha = ramc + sign * fraction * (pi / 2);
    var lambda = atan2(sin(targetAlpha) / cosEps, cos(targetAlpha));
    for (var i = 0; i < 30; i++) {
      final sinDelta = sinEps * sin(lambda);
      final delta = asin(sinDelta.clamp(-1.0, 1.0));
      final cosSA = -tanPhi * tan(delta);
      if (cosSA.abs() >= 1.0) return null; // circumpolar point
      final sa = acos(cosSA);
      targetAlpha = ramc + sign * fraction * sa;
      final newLambda = atan2(sin(targetAlpha) / cosEps, cos(targetAlpha));
      final diff = (newLambda - lambda).abs();
      lambda = newLambda;
      if (diff < 1e-7) {
        var deg = lambda * _rad2deg;
        deg = deg % 360;
        if (deg < 0) deg += 360;
        return deg;
      }
    }
    return null; // failed to converge
  }

  // Above-horizon intermediate cusps. Houses progress FORWARD on the
  // ecliptic from MC to ASC (via h11, h12). In hour-angle terms, MC is
  // at HA=0 and ASC is at HA=+SA (astrology convention — α > LST).
  // Cusp 11 is closer to MC (fraction 1/3 of SA past MC), cusp 12 is
  // closer to ASC (fraction 2/3 past MC).
  final cusp11 = solve(1 / 3, 1);
  final cusp12 = solve(2 / 3, 1);
  // Between DESC and MC (on the west) we mirror: cusp 9 close to MC
  // (α < LST), cusp 8 close to DESC.
  final cusp9 = solve(1 / 3, -1);
  final cusp8 = solve(2 / 3, -1);
  if (cusp8 == null || cusp9 == null || cusp11 == null || cusp12 == null) {
    return null;
  }

  // The below-horizon cusps are the ecliptic opposites of the above-
  // horizon cusps on the other side of the chart.
  final cusp2 = (cusp8 + 180) % 360;
  final cusp3 = (cusp9 + 180) % 360;
  final cusp5 = (cusp11 + 180) % 360;
  final cusp6 = (cusp12 + 180) % 360;

  return [
    asc, //  1
    cusp2, //  2
    cusp3, //  3
    (mc + 180) % 360, //  4  IC
    cusp5, //  5
    cusp6, //  6
    (asc + 180) % 360, //  7  DESC
    cusp8, //  8
    cusp9, //  9
    mc, // 10
    cusp11, // 11
    cusp12, // 12
  ];
}

/// Porphyry house cusps — trisect each ecliptic quadrant between the four
/// angles (ASC, IC, DESC, MC). Deterministic, no iteration.
///
/// Houses progress forward on the ecliptic: starting from ASC and going
/// through increasing ecliptic longitude, we pass h2, h3, IC (h4), h5,
/// h6, DESC (h7), h8, h9, MC (h10), h11, h12, back to ASC. Each
/// quadrant's arc is trisected, producing two intermediate cusps per
/// quadrant.
List<double> _porphyryCusps(double asc, double mc) {
  final ic = (mc + 180) % 360;
  final desc = (asc + 180) % 360;

  double trisect(double from, double to, double fraction) {
    final arc = (to - from + 360) % 360;
    return (from + arc * fraction) % 360;
  }

  final cusps = List<double>.filled(12, 0);
  cusps[0] = asc; // 1st
  cusps[3] = ic; // 4th
  cusps[6] = desc; // 7th
  cusps[9] = mc; // 10th

  // Forward arc from ASC to IC holds houses 2 and 3.
  cusps[1] = trisect(asc, ic, 1 / 3); // 2nd (closer to ASC)
  cusps[2] = trisect(asc, ic, 2 / 3); // 3rd (closer to IC)

  // Forward arc from IC to DESC holds houses 5 and 6.
  cusps[4] = trisect(ic, desc, 1 / 3); // 5th
  cusps[5] = trisect(ic, desc, 2 / 3); // 6th

  // Forward arc from DESC to MC holds houses 8 and 9.
  cusps[7] = trisect(desc, mc, 1 / 3); // 8th
  cusps[8] = trisect(desc, mc, 2 / 3); // 9th

  // Forward arc from MC to ASC holds houses 11 and 12.
  cusps[10] = trisect(mc, asc, 1 / 3); // 11th
  cusps[11] = trisect(mc, asc, 2 / 3); // 12th

  return cusps;
}
