import 'package:freezed_annotation/freezed_annotation.dart';
import 'geo_location.dart';
import 'planet.dart';

part 'birth_chart.freezed.dart';
part 'birth_chart.g.dart';

@freezed
abstract class BirthChart with _$BirthChart {
  const factory BirthChart({
    required String id,
    required DateTime birthDateTime,
    required GeoLocation birthLocation,
    // Ecliptic longitude (0-360) for each planet at birth.
    @PlanetMapConverter() required Map<Planet, double> planetPositions,
    /// 12 house cusp longitudes (Placidus or Equal House).
    required List<double> houseCusps,
    /// Whether the user knew their exact birth time. Defaults to `false` —
    /// flipping this on must be an explicit decision (onboarding sets it
    /// `true` only when the user enters a real time, otherwise leaves it
    /// false). Phase 1 of chart-as-proof relies on this to avoid claiming
    /// house placements for noon-default users with false confidence.
    @Default(false) bool exactTimeKnown,
    /// Ephemeris engine version that computed `planetPositions`/`houseCusps`
    /// (see `currentEngineVersion` in services/astronomy/planet_position.dart).
    /// Defaults to 0 so charts persisted before this field existed
    /// deserialize as stale and get recomputed on bootstrap.
    @Default(0) int engineVersion,
    required DateTime calculatedAt,
  }) = _BirthChart;

  factory BirthChart.fromJson(Map<String, dynamic> json) =>
      _$BirthChartFromJson(json);
}

// Converts Map<Planet, double> to/from Map<String, double> for JSON.
class PlanetMapConverter
    implements JsonConverter<Map<Planet, double>, Map<String, dynamic>> {
  const PlanetMapConverter();

  @override
  Map<Planet, double> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(
        Planet.values.firstWhere((p) => p.name == key),
        (value as num).toDouble(),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<Planet, double> object) {
    return object.map((key, value) => MapEntry(key.name, value));
  }
}
