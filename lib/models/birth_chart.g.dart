// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'birth_chart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BirthChart _$BirthChartFromJson(Map<String, dynamic> json) => _BirthChart(
  id: json['id'] as String,
  birthDateTime: DateTime.parse(json['birthDateTime'] as String),
  birthLocation: GeoLocation.fromJson(
    json['birthLocation'] as Map<String, dynamic>,
  ),
  planetPositions: const PlanetMapConverter().fromJson(
    json['planetPositions'] as Map<String, dynamic>,
  ),
  houseCusps: (json['houseCusps'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
  exactTimeKnown: json['exactTimeKnown'] as bool? ?? false,
  engineVersion: (json['engineVersion'] as num?)?.toInt() ?? 0,
  calculatedAt: DateTime.parse(json['calculatedAt'] as String),
);

Map<String, dynamic> _$BirthChartToJson(_BirthChart instance) =>
    <String, dynamic>{
      'id': instance.id,
      'birthDateTime': instance.birthDateTime.toIso8601String(),
      'birthLocation': instance.birthLocation,
      'planetPositions': const PlanetMapConverter().toJson(
        instance.planetPositions,
      ),
      'houseCusps': instance.houseCusps,
      'exactTimeKnown': instance.exactTimeKnown,
      'engineVersion': instance.engineVersion,
      'calculatedAt': instance.calculatedAt.toIso8601String(),
    };
