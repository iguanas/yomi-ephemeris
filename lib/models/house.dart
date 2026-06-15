// The 12 astrological houses — life areas mapped from birth location.

/// Life areas derived from birth location and time.
enum House {
  first(number: 1, lifeArea: 'Self & Identity', pillLabel: 'Self', keywords: ['identity', 'appearance', 'beginnings']),
  second(number: 2, lifeArea: 'Money & Values', pillLabel: 'Money', keywords: ['finances', 'possessions', 'self-worth']),
  third(number: 3, lifeArea: 'Communication', pillLabel: 'Communication', keywords: ['learning', 'siblings', 'short trips']),
  fourth(number: 4, lifeArea: 'Home & Family', pillLabel: 'Home', keywords: ['roots', 'parents', 'emotional foundation']),
  fifth(number: 5, lifeArea: 'Creativity & Romance', pillLabel: 'Creativity', keywords: ['pleasure', 'children', 'self-expression']),
  sixth(number: 6, lifeArea: 'Health & Routine', pillLabel: 'Health', keywords: ['daily work', 'service', 'wellness']),
  seventh(number: 7, lifeArea: 'Relationships', pillLabel: 'Love', keywords: ['partnerships', 'marriage', 'contracts']),
  eighth(number: 8, lifeArea: 'Transformation', pillLabel: 'Transformation', keywords: ['shared resources', 'rebirth', 'intimacy']),
  ninth(number: 9, lifeArea: 'Beliefs & Travel', pillLabel: 'Travel', keywords: ['philosophy', 'higher education', 'foreign lands']),
  tenth(number: 10, lifeArea: 'Career & Status', pillLabel: 'Career', keywords: ['reputation', 'authority', 'public image']),
  eleventh(number: 11, lifeArea: 'Community & Hopes', pillLabel: 'Community', keywords: ['friendships', 'groups', 'aspirations']),
  twelfth(number: 12, lifeArea: 'Spirituality', pillLabel: 'Spirituality', keywords: ['subconscious', 'solitude', 'hidden strengths']);

  const House({
    required this.number,
    required this.lifeArea,
    required this.pillLabel,
    required this.keywords,
  });

  final int number;
  final String lifeArea;
  final String pillLabel;
  final List<String> keywords;

  /// Sentence-insertable phrase for each house. Intended for templates like
  /// "Your $areaPhrase wants your attention" — so this returns a bare noun
  /// phrase (no possessive) that reads naturally when prefixed with "your"
  /// or slotted into "in your $areaPhrase" constructions.
  ///
  /// Compound `lifeArea` values ("Money & Values", "Community & Hopes") read
  /// as awkward AI copy when spliced raw into prose — this getter rewrites
  /// them into natural English. Single-word life areas get a slightly
  /// rephrased form too, so every call site can use one uniform helper.
  String get areaPhrase {
    switch (this) {
      case House.first:
        return 'sense of self';
      case House.second:
        return 'money and self-worth';
      case House.third:
        return 'communication';
      case House.fourth:
        return 'home life';
      case House.fifth:
        return 'creative life';
      case House.sixth:
        return 'daily health';
      case House.seventh:
        return 'relationships';
      case House.eighth:
        return 'deeper work';
      case House.ninth:
        return 'beliefs';
      case House.tenth:
        return 'work and reputation';
      case House.eleventh:
        return 'social world';
      case House.twelfth:
        return 'inner life';
    }
  }

  /// Ordinal display (e.g., "1st", "2nd", "3rd").
  String get ordinal {
    return switch (number) {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      _ => '${number}th',
    };
  }

  /// Determines which house a planet at [longitude] falls in, given [cusps].
  /// [cusps] is a list of 12 ecliptic longitudes for house cusp boundaries.
  static House fromLongitude(double longitude, List<double> cusps) {
    final normalizedLon = longitude % 360;
    for (var i = 0; i < 12; i++) {
      final nextI = (i + 1) % 12;
      final cuspStart = cusps[i];
      final cuspEnd = cusps[nextI];

      if (cuspEnd > cuspStart) {
        if (normalizedLon >= cuspStart && normalizedLon < cuspEnd) {
          return House.values[i];
        }
      } else {
        // Wraps around 0°/360°
        if (normalizedLon >= cuspStart || normalizedLon < cuspEnd) {
          return House.values[i];
        }
      }
    }
    return House.first; // fallback
  }
}
