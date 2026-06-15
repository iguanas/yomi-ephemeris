// Geometric angles between planets and whether they're building or fading.

/// The five major aspects used in astrology. Quincunx (150°) is deliberately
/// excluded — see `how_it_works_screen.dart` "what we deliberately leave out"
/// and the 2026-05-21 decision in the voice & quality plan: the bank covers
/// the five majors, and the runtime fallback for minor aspects produced
/// off-brand ungrammatical content. Dropping quincunx aligns code with the
/// brand promise.
enum AspectType {
  conjunction(
    angle: 0,
    symbol: '\u260C',
    displayName: 'Conjunction',
    nature: AspectNature.neutral,
  ),
  sextile(
    angle: 60,
    symbol: '\u26B9',
    displayName: 'Sextile',
    nature: AspectNature.harmonious,
  ),
  square(
    angle: 90,
    symbol: '\u25A1',
    displayName: 'Square',
    nature: AspectNature.challenging,
  ),
  trine(
    angle: 120,
    symbol: '\u25B3',
    displayName: 'Trine',
    nature: AspectNature.harmonious,
  ),
  opposition(
    angle: 180,
    symbol: '\u260D',
    displayName: 'Opposition',
    nature: AspectNature.challenging,
  );

  const AspectType({
    required this.angle,
    required this.symbol,
    required this.displayName,
    required this.nature,
  });

  final double angle;
  final String symbol;
  final String displayName;
  final AspectNature nature;
}

enum AspectNature { harmonious, challenging, neutral }

/// Whether the aspect is getting tighter (building) or past peak (fading).
enum AspectDirection {
  applying(displayName: 'Applying', description: 'Energy building toward peak'),
  separating(displayName: 'Separating', description: 'Energy fading from peak'),
  exact(displayName: 'Exact', description: 'At peak intensity');

  const AspectDirection({required this.displayName, required this.description});

  final String displayName;
  final String description;
}

/// Short plain-English descriptions of each aspect. Surfaced inside the
/// "?" equation dialog (see home_screen `_showAspectExplanation` and
/// `AspectExplanationContent`) as the THE ASPECT row. Kept here rather than
/// inline in home_screen so it
/// stays adjacent to the AspectType enum it describes, and so any future
/// surface that needs the same copy doesn't have to reach into private
/// feature code.
const Map<AspectType, String> aspectExplanations = {
  AspectType.conjunction:
      'Two forces merging into one. They blend, for better or worse.',
  AspectType.sextile:
      'Supportive angle. Things cooperate if you lean in.',
  AspectType.square:
      "Friction. The tension forces action. That's the point.",
  AspectType.trine:
      'Flowing. They work together without much effort.',
  AspectType.opposition:
      'A seesaw. Two pulls asking you to find the middle.',
};

/// One-line plain-English phrase that pairs with the technical aspect name in
/// places where the full sentence in [aspectExplanations] would crowd the
/// layout — most importantly the planet tooltip's Active Aspects list, which
/// shows multiple aspects at once. Keeps the astrology term ("trine",
/// "sextile", etc.) but teaches the meaning beside it so non-astrology users
/// aren't left decoding jargon.
const Map<AspectType, String> aspectPhrases = {
  AspectType.conjunction: 'merging energies',
  AspectType.sextile: 'opportunity to act',
  AspectType.square: 'productive tension',
  AspectType.trine: 'flowing harmony',
  AspectType.opposition: 'pulling toward balance',
};

/// Adjective/verb spellings the model uses for an aspect in place of the
/// canonical enum noun (e.g. "Uranus conjunct Mercury" rather than
/// "conjunction"). Validators consult this after an exact enum-name match, so a
/// normal label parses + verifies instead of being dropped (which, on a
/// single-citation answer, then trips the proof floor and fails the turn —
/// Sentry 2026-05-31). Shared by ask_anything_validator + go_deeper_validator
/// so the two can't drift.
const Map<String, AspectType> aspectWordAliases = {
  'conjunct': AspectType.conjunction,
  'conjoins': AspectType.conjunction,
  'conjoined': AspectType.conjunction,
  'conj': AspectType.conjunction,
  'opposite': AspectType.opposition,
  'opposed': AspectType.opposition,
  'opposes': AspectType.opposition,
  'opposing': AspectType.opposition,
  'opp': AspectType.opposition,
  'squares': AspectType.square,
  'squaring': AspectType.square,
  'trines': AspectType.trine,
  'trining': AspectType.trine,
  'sextiles': AspectType.sextile,
  'sextiling': AspectType.sextile,
};
