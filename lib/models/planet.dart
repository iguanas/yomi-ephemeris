/// Celestial bodies used in birth chart and transit calculations.
enum Planet {
  sun(
    displayName: 'Sun',
    symbol: '\u2609',
    orbitalPeriodDays: 365.25,
    significanceRank: 4,
    defaultOrb: 2.0,
  ),
  moon(
    displayName: 'Moon',
    symbol: '\u263D',
    orbitalPeriodDays: 27.32,
    significanceRank: 1,
    defaultOrb: 4.0, // Wider than traditional (~2°) to ensure Moon transits are almost always active for UX freshness
  ),
  mercury(
    displayName: 'Mercury',
    symbol: '\u263F',
    orbitalPeriodDays: 87.97,
    significanceRank: 2,
    defaultOrb: 2.0,
  ),
  venus(
    displayName: 'Venus',
    symbol: '\u2640',
    orbitalPeriodDays: 224.70,
    significanceRank: 3,
    defaultOrb: 2.0,
  ),
  mars(
    displayName: 'Mars',
    symbol: '\u2642',
    orbitalPeriodDays: 686.97,
    significanceRank: 5,
    defaultOrb: 2.5,
  ),
  jupiter(
    displayName: 'Jupiter',
    symbol: '\u2643',
    orbitalPeriodDays: 4332.59,
    significanceRank: 6,
    defaultOrb: 2.5,
  ),
  saturn(
    displayName: 'Saturn',
    symbol: '\u2644',
    orbitalPeriodDays: 10759.22,
    significanceRank: 7,
    defaultOrb: 3.0,
  ),
  uranus(
    displayName: 'Uranus',
    symbol: '\u26E2',
    orbitalPeriodDays: 30688.5,
    significanceRank: 8,
    defaultOrb: 3.0,
  ),
  neptune(
    displayName: 'Neptune',
    symbol: '\u2646',
    orbitalPeriodDays: 60182.0,
    significanceRank: 9,
    defaultOrb: 3.0,
  ),
  pluto(
    displayName: 'Pluto',
    symbol: '\u2647',
    orbitalPeriodDays: 90560.0,
    significanceRank: 10,
    defaultOrb: 3.0,
  ),
  northNode(
    displayName: 'North Node',
    symbol: '\u260A',
    orbitalPeriodDays: 6793.5, // ~18.6 years
    significanceRank: 11,
    defaultOrb: 2.5,
  ),
  chiron(
    displayName: 'Chiron',
    symbol: '\u26B7',
    orbitalPeriodDays: 18500.0, // ~50.7 years
    significanceRank: 12,
    defaultOrb: 2.5,
  );

  const Planet({
    required this.displayName,
    required this.symbol,
    required this.orbitalPeriodDays,
    required this.significanceRank,
    required this.defaultOrb,
  });

  final String displayName;
  final String symbol;
  final double orbitalPeriodDays;

  /// Higher = more significant. Used to break orb ties.
  final int significanceRank;

  /// Default orb tolerance in degrees for transit detection.
  final double defaultOrb;

  /// Orbital ring index for orrery display (0 = innermost).
  int get orbitIndex => index;
}

/// Zodiac signs of the ecliptic belt.
enum ZodiacSign {
  aries(symbol: '\u2648', startDegree: 0, element: Element.fire, modality: Modality.cardinal),
  taurus(symbol: '\u2649', startDegree: 30, element: Element.earth, modality: Modality.fixed),
  gemini(symbol: '\u264A', startDegree: 60, element: Element.air, modality: Modality.mutable),
  cancer(symbol: '\u264B', startDegree: 90, element: Element.water, modality: Modality.cardinal),
  leo(symbol: '\u264C', startDegree: 120, element: Element.fire, modality: Modality.fixed),
  virgo(symbol: '\u264D', startDegree: 150, element: Element.earth, modality: Modality.mutable),
  libra(symbol: '\u264E', startDegree: 180, element: Element.air, modality: Modality.cardinal),
  scorpio(symbol: '\u264F', startDegree: 210, element: Element.water, modality: Modality.fixed),
  sagittarius(symbol: '\u2650', startDegree: 240, element: Element.fire, modality: Modality.mutable),
  capricorn(symbol: '\u2651', startDegree: 270, element: Element.earth, modality: Modality.cardinal),
  aquarius(symbol: '\u2652', startDegree: 300, element: Element.air, modality: Modality.fixed),
  pisces(symbol: '\u2653', startDegree: 330, element: Element.water, modality: Modality.mutable);

  const ZodiacSign({
    required this.symbol,
    required this.startDegree,
    required this.element,
    required this.modality,
  });

  final String symbol;
  final double startDegree;
  final Element element;
  final Modality modality;

  /// SVG asset path for this sign's gold glyph. Use these instead of the
  /// Unicode `symbol` character in any UI that wants the sign rendered in the
  /// app's house style — Unicode glyphs are picked up by iOS as colour
  /// emoji, which clashes with the rest of the typography.
  String get glyphAsset => 'assets/zodiac/$name.svg';

  /// Returns the zodiac sign for a given ecliptic longitude (0-360).
  static ZodiacSign fromLongitude(double longitude) {
    final normalized = longitude % 360;
    final idx = (normalized / 30).floor();
    return ZodiacSign.values[idx];
  }
}

enum Element { fire, earth, air, water }

enum Modality { cardinal, fixed, mutable }
