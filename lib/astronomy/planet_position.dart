import 'dart:math';
import '../models/planet.dart';

part 'chiron_table.dart';
part 'jupiter_table.dart';
part 'mars_table.dart';
part 'mercury_table.dart';
part 'neptune_table.dart';
part 'pluto_table.dart';
part 'saturn_table.dart';
part 'uranus_table.dart';
part 'venus_table.dart';

/// Calculates ecliptic longitude of planets. Sun/Moon/North Node use
/// simplified analytic algorithms (<0.05° for Sun/Moon); everything else
/// (Mercury–Pluto, Chiron) interpolates JPL Horizons lookup tables
/// (1900-2050, <0.1°) — good enough for astrology orbs.

/// Version of the ephemeris engine. Bump this whenever a change alters the
/// positions/cusps the engine computes (table regeneration, algorithm fix,
/// house-system change) — stored `BirthChart`s persist their computed values
/// and only recompute on bootstrap when their `engineVersion` is behind this
/// (see `UserProfileNotifier.migrateChartsForEngineVersion`).
///
/// History:
///   1 — 2026-06: Chiron Keplerian model replaced with JPL Horizons table
///       (was ~180° wrong); first versioned engine.
///   2 — 2026-06: Jupiter–Pluto tables resampled monthly → weekly (station
///       sag max 0.40° → <0.03°) and extended past 2050-12-31.
const int currentEngineVersion = 2;

/// Supported range, inclusive — the extent of the daily inner-planet tables
/// (the binding constraint; outer/Chiron tables run slightly longer, to
/// 2051-01-01/02). [planetLongitude] throws outside this range instead of
/// silently clamping to the first/last table sample: a clamped longitude
/// looks plausible and freezes in place, which is exactly the failure mode
/// the JPL audit exists to prevent. The app's onboarding picker already
/// floors at 1900-01-02 local for this reason.
final DateTime minSupportedUtc = DateTime.utc(1900, 1, 1, 12);
final DateTime maxSupportedUtc = DateTime.utc(2050, 12, 31, 12);

const _deg2rad = pi / 180;


/// Convert a UTC [DateTime] to Julian Day Number.
double julianDayNumber(DateTime dt) {
  final utc = dt.toUtc();
  var y = utc.year;
  var m = utc.month;
  final d = utc.day +
      utc.hour / 24.0 +
      utc.minute / 1440.0 +
      utc.second / 86400.0;

  if (m <= 2) {
    y -= 1;
    m += 12;
  }

  final a = (y / 100).floor();
  final b = 2 - a + (a / 4).floor();
  return (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      d +
      b -
      1524.5;
}

/// Centuries since J2000.0 epoch (2000-01-01 12:00 TT).
double julianCenturies(DateTime dt) {
  return (julianDayNumber(dt) - 2451545.0) / 36525.0;
}

/// Normalise an angle to 0–360.
double _norm360(double deg) {
  var result = deg % 360;
  if (result < 0) result += 360;
  return result;
}

/// Calculate geocentric ecliptic longitude for [planet] at [dateTime].
///
/// Throws [ArgumentError] outside [minSupportedUtc]..[maxSupportedUtc].
double planetLongitude(Planet planet, DateTime dateTime) {
  if (dateTime.isBefore(minSupportedUtc) || dateTime.isAfter(maxSupportedUtc)) {
    throw ArgumentError.value(
      dateTime,
      'dateTime',
      'outside the supported ephemeris range '
          '$minSupportedUtc..$maxSupportedUtc',
    );
  }
  final t = julianCenturies(dateTime);

  // Sun and Moon are already geocentric.
  if (planet == Planet.sun) return _sunLongitude(t);
  if (planet == Planet.moon) return _moonLongitude(t);

  // North Node: already geocentric (lunar orbit parameter)
  if (planet == Planet.northNode) return _meanNorthNodeLongitude(t);

  // Three bodies have JPL Horizons lookup tables with daily/monthly
  // samples: Mercury and Mars (daily; their Keplerian approximations
  // missed 10.5% and 6.6% of signs respectively) and Pluto (monthly;
  // VSOP87 doesn't cover Pluto).
  if (planet == Planet.mercury) {
    final jd = t * 36525.0 + 2451545.0;
    return _fromUniformTable(
      jd,
      _mercuryTableBaseJd,
      _mercuryTableStepDays,
      _mercuryTable,
    );
  }
  if (planet == Planet.mars) {
    final jd = t * 36525.0 + 2451545.0;
    return _fromUniformTable(
      jd,
      _marsTableBaseJd,
      _marsTableStepDays,
      _marsTable,
    );
  }
  // Outer planets have weekly JPL Horizons lookup tables (monthly until
  // 2026-06: monthly sampling sagged up to 0.40° at retrograde stations,
  // where the longitude curve bends hardest, and made the retrograde
  // flag wrong for 1-2 weeks around each station). Weekly sampling cuts
  // the max interpolation error ~16x (<0.03°). Pluto must be tabled
  // (VSOP87 excludes it); Jupiter/Saturn/Uranus/Neptune are tabled for
  // consistency and accuracy.
  if (planet == Planet.pluto) {
    return _plutoFromTable(t * 36525.0 + 2451545.0);
  }
  if (planet == Planet.jupiter) {
    return _interleavedTableLookup(t * 36525.0 + 2451545.0, _jupiterTable);
  }
  if (planet == Planet.saturn) {
    return _interleavedTableLookup(t * 36525.0 + 2451545.0, _saturnTable);
  }
  if (planet == Planet.uranus) {
    return _interleavedTableLookup(t * 36525.0 + 2451545.0, _uranusTable);
  }
  if (planet == Planet.neptune) {
    return _interleavedTableLookup(t * 36525.0 + 2451545.0, _neptuneTable);
  }

  // Chiron has a monthly JPL Horizons table like the other slow movers.
  // Its old Keplerian approximation was unsalvageable: mean-motion rates
  // ~100x too small AND wrong epoch elements (49° off at J2000 itself),
  // which pinned Chiron near ~200° (Libra) for every date.
  if (planet == Planet.chiron) {
    return _interleavedTableLookup(t * 36525.0 + 2451545.0, _chironTable);
  }

  if (planet == Planet.venus) {
    final jd = t * 36525.0 + 2451545.0;
    return _fromUniformTable(
      jd,
      _venusTableBaseJd,
      _venusTableStepDays,
      _venusTable,
    );
  }

  return 0.0; // unreachable — every Planet value is handled above.
}

/// Shared linear-interpolation lookup for the interleaved-format tables
/// (pluto/jupiter/saturn/uranus/neptune). Table is `[jd0, lon0, jd1,
/// lon1, ...]`; binary-searches by JD, handles the 360° wrap.
double _interleavedTableLookup(double jd, List<double> table) {
  if (jd <= table[0]) return table[1];
  final lastIndex = table.length - 2;
  if (jd >= table[lastIndex]) return table[lastIndex + 1];
  final n = table.length ~/ 2;
  var lo = 0;
  var hi = n - 1;
  while (hi - lo > 1) {
    final mid = (lo + hi) ~/ 2;
    if (table[mid * 2] <= jd) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  final jd0 = table[lo * 2];
  final lon0 = table[lo * 2 + 1];
  final jd1 = table[hi * 2];
  final lon1 = table[hi * 2 + 1];
  var dlon = lon1 - lon0;
  if (dlon > 180) dlon -= 360;
  if (dlon < -180) dlon += 360;
  final frac = (jd - jd0) / (jd1 - jd0);
  return _norm360(lon0 + frac * dlon);
}

/// Linear interpolation from a uniformly-sampled ephemeris table.
/// Handles the 360° wrap for fast-moving inner planets.
double _fromUniformTable(
  double jd,
  double baseJd,
  double stepDays,
  List<double> table,
) {
  final fIndex = (jd - baseJd) / stepDays;
  if (fIndex <= 0) return table[0];
  if (fIndex >= table.length - 1) return table[table.length - 1];
  final lo = fIndex.floor();
  final frac = fIndex - lo;
  final lon0 = table[lo];
  final lon1 = table[lo + 1];
  var dlon = lon1 - lon0;
  if (dlon > 180) dlon -= 360;
  if (dlon < -180) dlon += 360;
  return _norm360(lon0 + frac * dlon);
}

double _plutoFromTable(double jd) => _interleavedTableLookup(jd, _plutoTable);

/// Convert heliocentric longitude to geocentric using Earth's position.
/// Uses average orbital radii (semi-major axes in AU).
/// Unused since Chiron (the last Keplerian body) moved to a Horizons
/// table; kept because the `// ignore: unused_element` Keplerian
/// fallbacks below are heliocentric and need it if ever revived.
// ignore: unused_element
double _toGeocentric(double helioLonDeg, Planet planet, double t) {
  // Earth's heliocentric longitude = Sun's geocentric + 180°.
  final earthLon = _norm360(_sunLongitude(t) + 180.0) * _deg2rad;
  final planetLon = helioLonDeg * _deg2rad;

  // Average orbital radii (AU). Close enough for astrology-grade accuracy.
  const radii = {
    Planet.mercury: 0.387,
    Planet.venus: 0.723,
    Planet.mars: 1.524,
    Planet.jupiter: 5.203,
    Planet.saturn: 9.537,
    Planet.uranus: 19.191,
    Planet.neptune: 30.069,
    Planet.pluto: 39.482,
    Planet.chiron: 13.708, // average orbital radius in AU
  };
  const earthRadius = 1.0;

  final rp = radii[planet] ?? 1.0;
  // Geocentric position = planet vector minus Earth vector.
  final x = rp * cos(planetLon) - earthRadius * cos(earthLon);
  final y = rp * sin(planetLon) - earthRadius * sin(earthLon);

  return _norm360(atan2(y, x) / _deg2rad);
}

/// Batch calculation for all planets.
Map<Planet, double> allPlanetPositions(DateTime dateTime) {
  return {for (final p in Planet.values) p: planetLongitude(p, dateTime)};
}

/// Calculate the current Moon phase.
/// Returns a record with phase name, illumination percentage (0-100),
/// and emoji icon.
({String name, double illumination, String emoji}) moonPhase(DateTime dateTime) {
  final sunLon = planetLongitude(Planet.sun, dateTime);
  final moonLon = planetLongitude(Planet.moon, dateTime);

  // Elongation: Moon's angular distance ahead of the Sun
  var elongation = moonLon - sunLon;
  if (elongation < 0) elongation += 360;

  // Illumination approximation (0 at new, 100 at full)
  final illumination = ((1 - cos(elongation * _deg2rad)) / 2 * 100);

  // Phase name from elongation
  final String name;
  final String emoji;
  if (elongation < 22.5) {
    name = 'New Moon';
    emoji = '\u{1F311}';
  } else if (elongation < 67.5) {
    name = 'Waxing Crescent';
    emoji = '\u{1F312}';
  } else if (elongation < 112.5) {
    name = 'First Quarter';
    emoji = '\u{1F313}';
  } else if (elongation < 157.5) {
    name = 'Waxing Gibbous';
    emoji = '\u{1F314}';
  } else if (elongation < 202.5) {
    name = 'Full Moon';
    emoji = '\u{1F315}';
  } else if (elongation < 247.5) {
    name = 'Waning Gibbous';
    emoji = '\u{1F316}';
  } else if (elongation < 292.5) {
    name = 'Last Quarter';
    emoji = '\u{1F317}';
  } else if (elongation < 337.5) {
    name = 'Waning Crescent';
    emoji = '\u{1F318}';
  } else {
    name = 'New Moon';
    emoji = '\u{1F311}';
  }

  return (name: name, illumination: illumination, emoji: emoji);
}

/// Check if a planet is retrograde at the given time.
/// Compares position at [dateTime] vs [dateTime - 1 day].
/// If ecliptic longitude decreased, the planet is retrograde.
/// Sun and Moon are never retrograde.
bool isPlanetRetrograde(Planet planet, DateTime dateTime) {
  // Sun and Moon never go retrograde
  if (planet == Planet.sun || planet == Planet.moon) return false;
  // North Node is always retrograde (regresses through zodiac)
  if (planet == Planet.northNode) return true;

  final lonNow = planetLongitude(planet, dateTime);
  final lonYesterday = planetLongitude(
    planet,
    dateTime.subtract(const Duration(days: 1)),
  );

  // Compute forward motion (accounting for 360/0 boundary)
  var diff = lonNow - lonYesterday;
  if (diff > 180) diff -= 360;
  if (diff < -180) diff += 360;

  // Negative diff = planet moved backward = retrograde
  return diff < 0;
}

// ───────────────────────────────────────────────────────────────────────────
// Sun
// ───────────────────────────────────────────────────────────────────────────
double _sunLongitude(double t) {
  // Mean anomaly
  final m = _norm360(357.5291092 + 35999.0502909 * t) * _deg2rad;
  // Equation of center
  final c = (1.9146 - 0.004817 * t - 0.000014 * t * t) * sin(m) +
      (0.019993 - 0.000101 * t) * sin(2 * m) +
      0.00029 * sin(3 * m);
  // Sun's mean longitude
  final l0 = _norm360(280.46646 + 36000.76983 * t + 0.0003032 * t * t);
  return _norm360(l0 + c);
}

// ───────────────────────────────────────────────────────────────────────────
// Moon — simplified lunar theory
// ───────────────────────────────────────────────────────────────────────────
double _moonLongitude(double t) {
  // Mean longitude
  final lp = _norm360(218.3164477 +
      481267.88123421 * t -
      0.0015786 * t * t +
      t * t * t / 538841.0);
  // Mean anomaly of Moon
  final m = _norm360(134.9633964 +
      477198.8675055 * t +
      0.0087414 * t * t +
      t * t * t / 69699.0) *
      _deg2rad;
  // Mean anomaly of Sun
  final ms = _norm360(357.5291092 + 35999.0502909 * t) * _deg2rad;
  // Mean elongation
  final d = _norm360(297.8501921 +
      445267.1114034 * t -
      0.0018819 * t * t +
      t * t * t / 545868.0) *
      _deg2rad;
  // Argument of latitude
  final f = _norm360(93.2720950 +
      483202.0175233 * t -
      0.0036539 * t * t -
      t * t * t / 3526000.0) *
      _deg2rad;

  // Principal perturbation terms
  var longitude = lp +
      6.289 * sin(m) +
      1.274 * sin(2 * d - m) +
      0.658 * sin(2 * d) +
      0.214 * sin(2 * m) -
      0.186 * sin(ms) -
      0.114 * sin(2 * f) +
      0.059 * sin(2 * d - 2 * m) +
      0.057 * sin(2 * d - ms - m) +
      0.053 * sin(2 * d + m) +
      0.046 * sin(2 * d - ms) -
      0.041 * sin(ms - m) -
      0.035 * sin(d) -
      0.031 * sin(m + ms);

  return _norm360(longitude);
}

// ───────────────────────────────────────────────────────────────────────────
// Inner planets — mean anomaly + equation of center
// ───────────────────────────────────────────────────────────────────────────
// ignore: unused_element
double _mercuryLongitude(double t) {
  final l0 = _norm360(252.2509 + 149474.0722 * t);
  final m = _norm360(174.7948 + 149472.5153 * t) * _deg2rad;
  final c = 23.4400 * sin(m) + 2.9818 * sin(2 * m) + 0.5255 * sin(3 * m);
  return _norm360(l0 + c);
}

// ignore: unused_element
double _venusLongitude(double t) {
  final l0 = _norm360(181.9798 + 58519.2130 * t);
  final m = _norm360(50.4161 + 58517.8039 * t) * _deg2rad;
  final c = 0.7758 * sin(m) + 0.0033 * sin(2 * m);
  return _norm360(l0 + c);
}

// ignore: unused_element
double _marsLongitude(double t) {
  final l0 = _norm360(355.4330 + 19141.6964 * t);
  final m = _norm360(19.3730 + 19139.8585 * t) * _deg2rad;
  final c = 10.6912 * sin(m) + 0.6228 * sin(2 * m) + 0.0503 * sin(3 * m);
  return _norm360(l0 + c);
}

// ───────────────────────────────────────────────────────────────────────────
// Outer planets
// ───────────────────────────────────────────────────────────────────────────
// ignore: unused_element
double _jupiterLongitude(double t) {
  final l0 = _norm360(34.3515 + 3036.3027 * t);
  final m = _norm360(19.8950 + 3034.6874 * t) * _deg2rad;
  final c = 5.5549 * sin(m) + 0.1683 * sin(2 * m) + 0.0071 * sin(3 * m);
  return _norm360(l0 + c);
}

// ignore: unused_element
double _saturnLongitude(double t) {
  final l0 = _norm360(50.0774 + 1223.5110 * t);
  final m = _norm360(317.0207 + 1222.1138 * t) * _deg2rad;
  final c = 6.3585 * sin(m) + 0.2204 * sin(2 * m) + 0.0106 * sin(3 * m);
  return _norm360(l0 + c);
}

// ignore: unused_element
double _uranusLongitude(double t) {
  final l0 = _norm360(314.0550 + 429.8640 * t);
  final m = _norm360(141.0498 + 429.0066 * t) * _deg2rad;
  final c = 5.3118 * sin(m) + 0.1384 * sin(2 * m);
  return _norm360(l0 + c);
}

// ignore: unused_element
double _neptuneLongitude(double t) {
  final l0 = _norm360(304.3487 + 219.8833 * t);
  final m = _norm360(256.2250 + 219.1894 * t) * _deg2rad;
  final c = 1.0302 * sin(m) + 0.0058 * sin(2 * m);
  return _norm360(l0 + c);
}

// Pluto is handled by `_plutoFromTable` at the top of `planetLongitude`,
// not by a Keplerian approximation — the VSOP-class model missed 11.2%
// of signs in the JPL audit. Kept here as a fallback reference if the
// table is ever regenerated out of sync.
// ignore: unused_element
double _plutoLongitudeKeplerian(double t) {
  final l0 = _norm360(238.9281 + 145.1781 * t);
  final m = _norm360(25.2471 + 144.1400 * t) * _deg2rad;
  final c = 28.3150 * sin(m) + 4.7921 * sin(2 * m) + 0.9868 * sin(3 * m);
  return _norm360(l0 + c);
}

// ───────────────────────────────────────────────────────────────────────────
// North Node (Mean)
// ───────────────────────────────────────────────────────────────────────────
double _meanNorthNodeLongitude(double t) {
  // Mean longitude of the ascending node of the Moon's orbit.
  // Regresses (moves backward) through the zodiac in ~18.6 years.
  // Based on Meeus, Astronomical Algorithms, Ch. 47.
  return _norm360(125.0445479 - 1934.1362891 * t +
      0.0020754 * t * t +
      t * t * t / 467441.0 -
      t * t * t * t / 60616000.0);
}

// Chiron is handled by `_chironTable` in `planetLongitude` — its Keplerian
// approximation was removed (not kept as a fallback like the gas giants')
// because it was broken beyond reuse: mean motions ~100x too small and
// wrong epoch elements. Chiron samples live in the shared fixture
// `test/fixtures/jpl_ephemeris.json`; regenerate the table with
// `dart run tools/gen_horizons_monthly_table.dart --body chiron`.
