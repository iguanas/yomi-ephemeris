import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo_location.freezed.dart';
part 'geo_location.g.dart';

@freezed
abstract class GeoLocation with _$GeoLocation {
  const GeoLocation._();

  const factory GeoLocation({
    required double latitude,
    required double longitude,
    required String cityName,
    required String countryCode,
    /// IANA timezone string, e.g. "America/New_York".
    required String timezone,
    /// Admin1 / state / province name when known (e.g. "Illinois", "Île-de-France").
    /// Optional so older serialized records remain readable.
    String? admin1,
  }) = _GeoLocation;

  factory GeoLocation.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationFromJson(json);

  /// Human label for the picker / summary UI: "Chicago, Illinois, US".
  /// When admin1 isn't set we fall back to "City, CC".
  String get displayLabel {
    final a = admin1;
    if (a != null && a.isNotEmpty) return '$cityName, $a, $countryCode';
    return '$cityName, $countryCode';
  }
}
