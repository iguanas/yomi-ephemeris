// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transit _$TransitFromJson(Map<String, dynamic> json) => _Transit(
  id: json['id'] as String,
  transitingPlanet: $enumDecode(_$PlanetEnumMap, json['transitingPlanet']),
  natalPlanet: $enumDecode(_$PlanetEnumMap, json['natalPlanet']),
  aspectType: $enumDecode(_$AspectTypeEnumMap, json['aspectType']),
  orb: (json['orb'] as num).toDouble(),
  direction: $enumDecode(_$AspectDirectionEnumMap, json['direction']),
  house: $enumDecode(_$HouseEnumMap, json['house']),
  peakTime: DateTime.parse(json['peakTime'] as String),
  windowStart: DateTime.parse(json['windowStart'] as String),
  windowEnd: DateTime.parse(json['windowEnd'] as String),
  transitingLongitude: (json['transitingLongitude'] as num).toDouble(),
  natalLongitude: (json['natalLongitude'] as num).toDouble(),
  isRetrograde: json['isRetrograde'] as bool? ?? false,
  phase:
      $enumDecodeNullable(_$TransitPhaseEnumMap, json['phase']) ??
      TransitPhase.active,
  priorityScore: (json['priorityScore'] as num?)?.toInt() ?? 0,
  isMajor: json['isMajor'] as bool? ?? false,
  headline: json['headline'] as String?,
  hook: json['hook'] as String?,
  readingPreview: json['readingPreview'] as String?,
  readingFull: json['readingFull'] as String?,
  transitingPlanetMeaning: json['transitingPlanetMeaning'] as String?,
  natalPlanetMeaning: json['natalPlanetMeaning'] as String?,
  houseMeaning: json['houseMeaning'] as String?,
);

Map<String, dynamic> _$TransitToJson(_Transit instance) => <String, dynamic>{
  'id': instance.id,
  'transitingPlanet': _$PlanetEnumMap[instance.transitingPlanet]!,
  'natalPlanet': _$PlanetEnumMap[instance.natalPlanet]!,
  'aspectType': _$AspectTypeEnumMap[instance.aspectType]!,
  'orb': instance.orb,
  'direction': _$AspectDirectionEnumMap[instance.direction]!,
  'house': _$HouseEnumMap[instance.house]!,
  'peakTime': instance.peakTime.toIso8601String(),
  'windowStart': instance.windowStart.toIso8601String(),
  'windowEnd': instance.windowEnd.toIso8601String(),
  'transitingLongitude': instance.transitingLongitude,
  'natalLongitude': instance.natalLongitude,
  'isRetrograde': instance.isRetrograde,
  'phase': _$TransitPhaseEnumMap[instance.phase]!,
  'priorityScore': instance.priorityScore,
  'isMajor': instance.isMajor,
  'headline': instance.headline,
  'hook': instance.hook,
  'readingPreview': instance.readingPreview,
  'readingFull': instance.readingFull,
  'transitingPlanetMeaning': instance.transitingPlanetMeaning,
  'natalPlanetMeaning': instance.natalPlanetMeaning,
  'houseMeaning': instance.houseMeaning,
};

const _$PlanetEnumMap = {
  Planet.sun: 'sun',
  Planet.moon: 'moon',
  Planet.mercury: 'mercury',
  Planet.venus: 'venus',
  Planet.mars: 'mars',
  Planet.jupiter: 'jupiter',
  Planet.saturn: 'saturn',
  Planet.uranus: 'uranus',
  Planet.neptune: 'neptune',
  Planet.pluto: 'pluto',
  Planet.northNode: 'northNode',
  Planet.chiron: 'chiron',
};

const _$AspectTypeEnumMap = {
  AspectType.conjunction: 'conjunction',
  AspectType.sextile: 'sextile',
  AspectType.square: 'square',
  AspectType.trine: 'trine',
  AspectType.opposition: 'opposition',
};

const _$AspectDirectionEnumMap = {
  AspectDirection.applying: 'applying',
  AspectDirection.separating: 'separating',
  AspectDirection.exact: 'exact',
};

const _$HouseEnumMap = {
  House.first: 'first',
  House.second: 'second',
  House.third: 'third',
  House.fourth: 'fourth',
  House.fifth: 'fifth',
  House.sixth: 'sixth',
  House.seventh: 'seventh',
  House.eighth: 'eighth',
  House.ninth: 'ninth',
  House.tenth: 'tenth',
  House.eleventh: 'eleventh',
  House.twelfth: 'twelfth',
};

const _$TransitPhaseEnumMap = {
  TransitPhase.forming: 'forming',
  TransitPhase.active: 'active',
  TransitPhase.peaking: 'peaking',
  TransitPhase.separating: 'separating',
};
