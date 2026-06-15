// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'birth_chart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BirthChart {

 String get id; DateTime get birthDateTime; GeoLocation get birthLocation;// Ecliptic longitude (0-360) for each planet at birth.
@PlanetMapConverter() Map<Planet, double> get planetPositions;/// 12 house cusp longitudes (Placidus or Equal House).
 List<double> get houseCusps;/// Whether the user knew their exact birth time. Defaults to `false` —
/// flipping this on must be an explicit decision (onboarding sets it
/// `true` only when the user enters a real time, otherwise leaves it
/// false). Phase 1 of chart-as-proof relies on this to avoid claiming
/// house placements for noon-default users with false confidence.
 bool get exactTimeKnown;/// Ephemeris engine version that computed `planetPositions`/`houseCusps`
/// (see `currentEngineVersion` in services/astronomy/planet_position.dart).
/// Defaults to 0 so charts persisted before this field existed
/// deserialize as stale and get recomputed on bootstrap.
 int get engineVersion; DateTime get calculatedAt;
/// Create a copy of BirthChart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BirthChartCopyWith<BirthChart> get copyWith => _$BirthChartCopyWithImpl<BirthChart>(this as BirthChart, _$identity);

  /// Serializes this BirthChart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BirthChart&&(identical(other.id, id) || other.id == id)&&(identical(other.birthDateTime, birthDateTime) || other.birthDateTime == birthDateTime)&&(identical(other.birthLocation, birthLocation) || other.birthLocation == birthLocation)&&const DeepCollectionEquality().equals(other.planetPositions, planetPositions)&&const DeepCollectionEquality().equals(other.houseCusps, houseCusps)&&(identical(other.exactTimeKnown, exactTimeKnown) || other.exactTimeKnown == exactTimeKnown)&&(identical(other.engineVersion, engineVersion) || other.engineVersion == engineVersion)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,birthDateTime,birthLocation,const DeepCollectionEquality().hash(planetPositions),const DeepCollectionEquality().hash(houseCusps),exactTimeKnown,engineVersion,calculatedAt);

@override
String toString() {
  return 'BirthChart(id: $id, birthDateTime: $birthDateTime, birthLocation: $birthLocation, planetPositions: $planetPositions, houseCusps: $houseCusps, exactTimeKnown: $exactTimeKnown, engineVersion: $engineVersion, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class $BirthChartCopyWith<$Res>  {
  factory $BirthChartCopyWith(BirthChart value, $Res Function(BirthChart) _then) = _$BirthChartCopyWithImpl;
@useResult
$Res call({
 String id, DateTime birthDateTime, GeoLocation birthLocation,@PlanetMapConverter() Map<Planet, double> planetPositions, List<double> houseCusps, bool exactTimeKnown, int engineVersion, DateTime calculatedAt
});


$GeoLocationCopyWith<$Res> get birthLocation;

}
/// @nodoc
class _$BirthChartCopyWithImpl<$Res>
    implements $BirthChartCopyWith<$Res> {
  _$BirthChartCopyWithImpl(this._self, this._then);

  final BirthChart _self;
  final $Res Function(BirthChart) _then;

/// Create a copy of BirthChart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? birthDateTime = null,Object? birthLocation = null,Object? planetPositions = null,Object? houseCusps = null,Object? exactTimeKnown = null,Object? engineVersion = null,Object? calculatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,birthDateTime: null == birthDateTime ? _self.birthDateTime : birthDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,birthLocation: null == birthLocation ? _self.birthLocation : birthLocation // ignore: cast_nullable_to_non_nullable
as GeoLocation,planetPositions: null == planetPositions ? _self.planetPositions : planetPositions // ignore: cast_nullable_to_non_nullable
as Map<Planet, double>,houseCusps: null == houseCusps ? _self.houseCusps : houseCusps // ignore: cast_nullable_to_non_nullable
as List<double>,exactTimeKnown: null == exactTimeKnown ? _self.exactTimeKnown : exactTimeKnown // ignore: cast_nullable_to_non_nullable
as bool,engineVersion: null == engineVersion ? _self.engineVersion : engineVersion // ignore: cast_nullable_to_non_nullable
as int,calculatedAt: null == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of BirthChart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoLocationCopyWith<$Res> get birthLocation {
  
  return $GeoLocationCopyWith<$Res>(_self.birthLocation, (value) {
    return _then(_self.copyWith(birthLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [BirthChart].
extension BirthChartPatterns on BirthChart {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BirthChart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BirthChart() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BirthChart value)  $default,){
final _that = this;
switch (_that) {
case _BirthChart():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BirthChart value)?  $default,){
final _that = this;
switch (_that) {
case _BirthChart() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime birthDateTime,  GeoLocation birthLocation, @PlanetMapConverter()  Map<Planet, double> planetPositions,  List<double> houseCusps,  bool exactTimeKnown,  int engineVersion,  DateTime calculatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BirthChart() when $default != null:
return $default(_that.id,_that.birthDateTime,_that.birthLocation,_that.planetPositions,_that.houseCusps,_that.exactTimeKnown,_that.engineVersion,_that.calculatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime birthDateTime,  GeoLocation birthLocation, @PlanetMapConverter()  Map<Planet, double> planetPositions,  List<double> houseCusps,  bool exactTimeKnown,  int engineVersion,  DateTime calculatedAt)  $default,) {final _that = this;
switch (_that) {
case _BirthChart():
return $default(_that.id,_that.birthDateTime,_that.birthLocation,_that.planetPositions,_that.houseCusps,_that.exactTimeKnown,_that.engineVersion,_that.calculatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime birthDateTime,  GeoLocation birthLocation, @PlanetMapConverter()  Map<Planet, double> planetPositions,  List<double> houseCusps,  bool exactTimeKnown,  int engineVersion,  DateTime calculatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BirthChart() when $default != null:
return $default(_that.id,_that.birthDateTime,_that.birthLocation,_that.planetPositions,_that.houseCusps,_that.exactTimeKnown,_that.engineVersion,_that.calculatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BirthChart implements BirthChart {
  const _BirthChart({required this.id, required this.birthDateTime, required this.birthLocation, @PlanetMapConverter() required final  Map<Planet, double> planetPositions, required final  List<double> houseCusps, this.exactTimeKnown = false, this.engineVersion = 0, required this.calculatedAt}): _planetPositions = planetPositions,_houseCusps = houseCusps;
  factory _BirthChart.fromJson(Map<String, dynamic> json) => _$BirthChartFromJson(json);

@override final  String id;
@override final  DateTime birthDateTime;
@override final  GeoLocation birthLocation;
// Ecliptic longitude (0-360) for each planet at birth.
 final  Map<Planet, double> _planetPositions;
// Ecliptic longitude (0-360) for each planet at birth.
@override@PlanetMapConverter() Map<Planet, double> get planetPositions {
  if (_planetPositions is EqualUnmodifiableMapView) return _planetPositions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_planetPositions);
}

/// 12 house cusp longitudes (Placidus or Equal House).
 final  List<double> _houseCusps;
/// 12 house cusp longitudes (Placidus or Equal House).
@override List<double> get houseCusps {
  if (_houseCusps is EqualUnmodifiableListView) return _houseCusps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_houseCusps);
}

/// Whether the user knew their exact birth time. Defaults to `false` —
/// flipping this on must be an explicit decision (onboarding sets it
/// `true` only when the user enters a real time, otherwise leaves it
/// false). Phase 1 of chart-as-proof relies on this to avoid claiming
/// house placements for noon-default users with false confidence.
@override@JsonKey() final  bool exactTimeKnown;
/// Ephemeris engine version that computed `planetPositions`/`houseCusps`
/// (see `currentEngineVersion` in services/astronomy/planet_position.dart).
/// Defaults to 0 so charts persisted before this field existed
/// deserialize as stale and get recomputed on bootstrap.
@override@JsonKey() final  int engineVersion;
@override final  DateTime calculatedAt;

/// Create a copy of BirthChart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BirthChartCopyWith<_BirthChart> get copyWith => __$BirthChartCopyWithImpl<_BirthChart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BirthChartToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BirthChart&&(identical(other.id, id) || other.id == id)&&(identical(other.birthDateTime, birthDateTime) || other.birthDateTime == birthDateTime)&&(identical(other.birthLocation, birthLocation) || other.birthLocation == birthLocation)&&const DeepCollectionEquality().equals(other._planetPositions, _planetPositions)&&const DeepCollectionEquality().equals(other._houseCusps, _houseCusps)&&(identical(other.exactTimeKnown, exactTimeKnown) || other.exactTimeKnown == exactTimeKnown)&&(identical(other.engineVersion, engineVersion) || other.engineVersion == engineVersion)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,birthDateTime,birthLocation,const DeepCollectionEquality().hash(_planetPositions),const DeepCollectionEquality().hash(_houseCusps),exactTimeKnown,engineVersion,calculatedAt);

@override
String toString() {
  return 'BirthChart(id: $id, birthDateTime: $birthDateTime, birthLocation: $birthLocation, planetPositions: $planetPositions, houseCusps: $houseCusps, exactTimeKnown: $exactTimeKnown, engineVersion: $engineVersion, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class _$BirthChartCopyWith<$Res> implements $BirthChartCopyWith<$Res> {
  factory _$BirthChartCopyWith(_BirthChart value, $Res Function(_BirthChart) _then) = __$BirthChartCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime birthDateTime, GeoLocation birthLocation,@PlanetMapConverter() Map<Planet, double> planetPositions, List<double> houseCusps, bool exactTimeKnown, int engineVersion, DateTime calculatedAt
});


@override $GeoLocationCopyWith<$Res> get birthLocation;

}
/// @nodoc
class __$BirthChartCopyWithImpl<$Res>
    implements _$BirthChartCopyWith<$Res> {
  __$BirthChartCopyWithImpl(this._self, this._then);

  final _BirthChart _self;
  final $Res Function(_BirthChart) _then;

/// Create a copy of BirthChart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? birthDateTime = null,Object? birthLocation = null,Object? planetPositions = null,Object? houseCusps = null,Object? exactTimeKnown = null,Object? engineVersion = null,Object? calculatedAt = null,}) {
  return _then(_BirthChart(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,birthDateTime: null == birthDateTime ? _self.birthDateTime : birthDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,birthLocation: null == birthLocation ? _self.birthLocation : birthLocation // ignore: cast_nullable_to_non_nullable
as GeoLocation,planetPositions: null == planetPositions ? _self._planetPositions : planetPositions // ignore: cast_nullable_to_non_nullable
as Map<Planet, double>,houseCusps: null == houseCusps ? _self._houseCusps : houseCusps // ignore: cast_nullable_to_non_nullable
as List<double>,exactTimeKnown: null == exactTimeKnown ? _self.exactTimeKnown : exactTimeKnown // ignore: cast_nullable_to_non_nullable
as bool,engineVersion: null == engineVersion ? _self.engineVersion : engineVersion // ignore: cast_nullable_to_non_nullable
as int,calculatedAt: null == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of BirthChart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoLocationCopyWith<$Res> get birthLocation {
  
  return $GeoLocationCopyWith<$Res>(_self.birthLocation, (value) {
    return _then(_self.copyWith(birthLocation: value));
  });
}
}

// dart format on
