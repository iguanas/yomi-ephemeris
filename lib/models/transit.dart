import 'package:freezed_annotation/freezed_annotation.dart';
import 'aspect.dart';
import 'house.dart';
import 'planet.dart';
import 'transit_phase.dart';

part 'transit.freezed.dart';
part 'transit.g.dart';

@freezed
abstract class Transit with _$Transit {
  const Transit._();

  const factory Transit({
    required String id,
    required Planet transitingPlanet,
    required Planet natalPlanet,
    required AspectType aspectType,
    /// How close to exact the aspect is (degrees). 0 = perfect.
    required double orb,
    required AspectDirection direction,
    /// Which natal house the transiting planet occupies.
    required House house,
    /// When the orb reaches its minimum (maximum intensity).
    required DateTime peakTime,
    /// When the transit entered orb tolerance.
    required DateTime windowStart,
    /// When the transit will leave orb tolerance.
    required DateTime windowEnd,
    required double transitingLongitude,
    required double natalLongitude,

    /// Whether the transiting planet is currently retrograde.
    @Default(false) bool isRetrograde,

    // New fields for river UI
    @Default(TransitPhase.active) TransitPhase phase,
    @Default(0) int priorityScore,
    @Default(false) bool isMajor,

    // Content fields (populated by reading bank or AI)
    String? headline,
    String? hook,
    String? readingPreview,
    String? readingFull,

    // Meaning fields (for equation display)
    String? transitingPlanetMeaning,
    String? natalPlanetMeaning,
    String? houseMeaning,
  }) = _Transit;

  factory Transit.fromJson(Map<String, dynamic> json) =>
      _$TransitFromJson(json);

  /// Duration of this transit in days (minimum 1 to prevent division by zero).
  int get durationDays {
    final days = windowEnd.difference(windowStart).inDays;
    return days < 1 ? 1 : days;
  }

  /// Which day we're on (1-based).
  int get currentDay {
    final elapsed = DateTime.now().difference(windowStart).inDays;
    return (elapsed + 1).clamp(1, durationDays);
  }

  /// Whether this transit lasts more than 7 days (show progress bar).
  bool get isLongTransit => durationDays > 7;

  /// Zodiac sign of the transiting planet.
  ZodiacSign get transitingSign => ZodiacSign.fromLongitude(transitingLongitude);

  /// Zodiac sign of the natal planet.
  ZodiacSign get natalSign => ZodiacSign.fromLongitude(natalLongitude);

  /// Degree within the sign (0-29).
  int get transitingDegree => (transitingLongitude % 30).floor();

  /// Degree within the sign (0-29).
  int get natalDegree => (natalLongitude % 30).floor();

  /// Speed-tier classification for the unified active-transit deck. The home
  /// reading leads with [TransitTier.today] (Moon), then backfills with
  /// [TransitTier.thisWeek] and [TransitTier.thisSeason] tagged as ongoing
  /// context. Timeline groups by tier.
  TransitTier get tier => transitTierFor(transitingPlanet);
}

/// Speed of the transiting body. Tiers map to "how often the user should
/// expect this card to feel like new news":
///   - [today]: Moon (changes every few hours)
///   - [thisWeek]: Sun, Mercury, Venus, Mars (days–weeks)
///   - [thisSeason]: Jupiter and slower (months–years)
enum TransitTier { today, thisWeek, thisSeason }

TransitTier transitTierFor(Planet planet) {
  switch (planet) {
    case Planet.moon:
      return TransitTier.today;
    case Planet.sun:
    case Planet.mercury:
    case Planet.venus:
    case Planet.mars:
      return TransitTier.thisWeek;
    case Planet.jupiter:
    case Planet.saturn:
    case Planet.uranus:
    case Planet.neptune:
    case Planet.pluto:
    case Planet.chiron:
    case Planet.northNode:
      return TransitTier.thisSeason;
  }
}

extension TransitTierLabel on TransitTier {
  /// Short uppercase tag shown on home/chart cards for non-Moon transits to
  /// signal the timescale ("you'll see this card again — it's ongoing"). Moon
  /// is the default "now" so it carries no tag.
  String get tagLabel {
    switch (this) {
      case TransitTier.today:
        return '';
      case TransitTier.thisWeek:
        return '';
      case TransitTier.thisSeason:
        // Slow majors only reach the home highlight deck when they just
        // activated or are peaking now, so the per-card tag should read as
        // freshness, not "this is just sitting there for months."
        return 'PEAKING NOW';
    }
  }

  /// Human label for sectioned lists (Timeline).
  String get sectionLabel {
    switch (this) {
      case TransitTier.today:
        return 'Today';
      case TransitTier.thisWeek:
        return 'This week';
      case TransitTier.thisSeason:
        return 'This season';
    }
  }
}
