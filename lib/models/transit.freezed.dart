// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Transit {

 String get id; Planet get transitingPlanet; Planet get natalPlanet; AspectType get aspectType;/// How close to exact the aspect is (degrees). 0 = perfect.
 double get orb; AspectDirection get direction;/// Which natal house the transiting planet occupies.
 House get house;/// When the orb reaches its minimum (maximum intensity).
 DateTime get peakTime;/// When the transit entered orb tolerance.
 DateTime get windowStart;/// When the transit will leave orb tolerance.
 DateTime get windowEnd; double get transitingLongitude; double get natalLongitude;/// Whether the transiting planet is currently retrograde.
 bool get isRetrograde;// New fields for river UI
 TransitPhase get phase; int get priorityScore; bool get isMajor;// Content fields (populated by reading bank or AI)
 String? get headline; String? get hook; String? get readingPreview; String? get readingFull;// Meaning fields (for equation display)
 String? get transitingPlanetMeaning; String? get natalPlanetMeaning; String? get houseMeaning;
/// Create a copy of Transit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransitCopyWith<Transit> get copyWith => _$TransitCopyWithImpl<Transit>(this as Transit, _$identity);

  /// Serializes this Transit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transit&&(identical(other.id, id) || other.id == id)&&(identical(other.transitingPlanet, transitingPlanet) || other.transitingPlanet == transitingPlanet)&&(identical(other.natalPlanet, natalPlanet) || other.natalPlanet == natalPlanet)&&(identical(other.aspectType, aspectType) || other.aspectType == aspectType)&&(identical(other.orb, orb) || other.orb == orb)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.house, house) || other.house == house)&&(identical(other.peakTime, peakTime) || other.peakTime == peakTime)&&(identical(other.windowStart, windowStart) || other.windowStart == windowStart)&&(identical(other.windowEnd, windowEnd) || other.windowEnd == windowEnd)&&(identical(other.transitingLongitude, transitingLongitude) || other.transitingLongitude == transitingLongitude)&&(identical(other.natalLongitude, natalLongitude) || other.natalLongitude == natalLongitude)&&(identical(other.isRetrograde, isRetrograde) || other.isRetrograde == isRetrograde)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.priorityScore, priorityScore) || other.priorityScore == priorityScore)&&(identical(other.isMajor, isMajor) || other.isMajor == isMajor)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.hook, hook) || other.hook == hook)&&(identical(other.readingPreview, readingPreview) || other.readingPreview == readingPreview)&&(identical(other.readingFull, readingFull) || other.readingFull == readingFull)&&(identical(other.transitingPlanetMeaning, transitingPlanetMeaning) || other.transitingPlanetMeaning == transitingPlanetMeaning)&&(identical(other.natalPlanetMeaning, natalPlanetMeaning) || other.natalPlanetMeaning == natalPlanetMeaning)&&(identical(other.houseMeaning, houseMeaning) || other.houseMeaning == houseMeaning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,transitingPlanet,natalPlanet,aspectType,orb,direction,house,peakTime,windowStart,windowEnd,transitingLongitude,natalLongitude,isRetrograde,phase,priorityScore,isMajor,headline,hook,readingPreview,readingFull,transitingPlanetMeaning,natalPlanetMeaning,houseMeaning]);

@override
String toString() {
  return 'Transit(id: $id, transitingPlanet: $transitingPlanet, natalPlanet: $natalPlanet, aspectType: $aspectType, orb: $orb, direction: $direction, house: $house, peakTime: $peakTime, windowStart: $windowStart, windowEnd: $windowEnd, transitingLongitude: $transitingLongitude, natalLongitude: $natalLongitude, isRetrograde: $isRetrograde, phase: $phase, priorityScore: $priorityScore, isMajor: $isMajor, headline: $headline, hook: $hook, readingPreview: $readingPreview, readingFull: $readingFull, transitingPlanetMeaning: $transitingPlanetMeaning, natalPlanetMeaning: $natalPlanetMeaning, houseMeaning: $houseMeaning)';
}


}

/// @nodoc
abstract mixin class $TransitCopyWith<$Res>  {
  factory $TransitCopyWith(Transit value, $Res Function(Transit) _then) = _$TransitCopyWithImpl;
@useResult
$Res call({
 String id, Planet transitingPlanet, Planet natalPlanet, AspectType aspectType, double orb, AspectDirection direction, House house, DateTime peakTime, DateTime windowStart, DateTime windowEnd, double transitingLongitude, double natalLongitude, bool isRetrograde, TransitPhase phase, int priorityScore, bool isMajor, String? headline, String? hook, String? readingPreview, String? readingFull, String? transitingPlanetMeaning, String? natalPlanetMeaning, String? houseMeaning
});




}
/// @nodoc
class _$TransitCopyWithImpl<$Res>
    implements $TransitCopyWith<$Res> {
  _$TransitCopyWithImpl(this._self, this._then);

  final Transit _self;
  final $Res Function(Transit) _then;

/// Create a copy of Transit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? transitingPlanet = null,Object? natalPlanet = null,Object? aspectType = null,Object? orb = null,Object? direction = null,Object? house = null,Object? peakTime = null,Object? windowStart = null,Object? windowEnd = null,Object? transitingLongitude = null,Object? natalLongitude = null,Object? isRetrograde = null,Object? phase = null,Object? priorityScore = null,Object? isMajor = null,Object? headline = freezed,Object? hook = freezed,Object? readingPreview = freezed,Object? readingFull = freezed,Object? transitingPlanetMeaning = freezed,Object? natalPlanetMeaning = freezed,Object? houseMeaning = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transitingPlanet: null == transitingPlanet ? _self.transitingPlanet : transitingPlanet // ignore: cast_nullable_to_non_nullable
as Planet,natalPlanet: null == natalPlanet ? _self.natalPlanet : natalPlanet // ignore: cast_nullable_to_non_nullable
as Planet,aspectType: null == aspectType ? _self.aspectType : aspectType // ignore: cast_nullable_to_non_nullable
as AspectType,orb: null == orb ? _self.orb : orb // ignore: cast_nullable_to_non_nullable
as double,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as AspectDirection,house: null == house ? _self.house : house // ignore: cast_nullable_to_non_nullable
as House,peakTime: null == peakTime ? _self.peakTime : peakTime // ignore: cast_nullable_to_non_nullable
as DateTime,windowStart: null == windowStart ? _self.windowStart : windowStart // ignore: cast_nullable_to_non_nullable
as DateTime,windowEnd: null == windowEnd ? _self.windowEnd : windowEnd // ignore: cast_nullable_to_non_nullable
as DateTime,transitingLongitude: null == transitingLongitude ? _self.transitingLongitude : transitingLongitude // ignore: cast_nullable_to_non_nullable
as double,natalLongitude: null == natalLongitude ? _self.natalLongitude : natalLongitude // ignore: cast_nullable_to_non_nullable
as double,isRetrograde: null == isRetrograde ? _self.isRetrograde : isRetrograde // ignore: cast_nullable_to_non_nullable
as bool,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as TransitPhase,priorityScore: null == priorityScore ? _self.priorityScore : priorityScore // ignore: cast_nullable_to_non_nullable
as int,isMajor: null == isMajor ? _self.isMajor : isMajor // ignore: cast_nullable_to_non_nullable
as bool,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,hook: freezed == hook ? _self.hook : hook // ignore: cast_nullable_to_non_nullable
as String?,readingPreview: freezed == readingPreview ? _self.readingPreview : readingPreview // ignore: cast_nullable_to_non_nullable
as String?,readingFull: freezed == readingFull ? _self.readingFull : readingFull // ignore: cast_nullable_to_non_nullable
as String?,transitingPlanetMeaning: freezed == transitingPlanetMeaning ? _self.transitingPlanetMeaning : transitingPlanetMeaning // ignore: cast_nullable_to_non_nullable
as String?,natalPlanetMeaning: freezed == natalPlanetMeaning ? _self.natalPlanetMeaning : natalPlanetMeaning // ignore: cast_nullable_to_non_nullable
as String?,houseMeaning: freezed == houseMeaning ? _self.houseMeaning : houseMeaning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Transit].
extension TransitPatterns on Transit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transit value)  $default,){
final _that = this;
switch (_that) {
case _Transit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transit value)?  $default,){
final _that = this;
switch (_that) {
case _Transit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Planet transitingPlanet,  Planet natalPlanet,  AspectType aspectType,  double orb,  AspectDirection direction,  House house,  DateTime peakTime,  DateTime windowStart,  DateTime windowEnd,  double transitingLongitude,  double natalLongitude,  bool isRetrograde,  TransitPhase phase,  int priorityScore,  bool isMajor,  String? headline,  String? hook,  String? readingPreview,  String? readingFull,  String? transitingPlanetMeaning,  String? natalPlanetMeaning,  String? houseMeaning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transit() when $default != null:
return $default(_that.id,_that.transitingPlanet,_that.natalPlanet,_that.aspectType,_that.orb,_that.direction,_that.house,_that.peakTime,_that.windowStart,_that.windowEnd,_that.transitingLongitude,_that.natalLongitude,_that.isRetrograde,_that.phase,_that.priorityScore,_that.isMajor,_that.headline,_that.hook,_that.readingPreview,_that.readingFull,_that.transitingPlanetMeaning,_that.natalPlanetMeaning,_that.houseMeaning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Planet transitingPlanet,  Planet natalPlanet,  AspectType aspectType,  double orb,  AspectDirection direction,  House house,  DateTime peakTime,  DateTime windowStart,  DateTime windowEnd,  double transitingLongitude,  double natalLongitude,  bool isRetrograde,  TransitPhase phase,  int priorityScore,  bool isMajor,  String? headline,  String? hook,  String? readingPreview,  String? readingFull,  String? transitingPlanetMeaning,  String? natalPlanetMeaning,  String? houseMeaning)  $default,) {final _that = this;
switch (_that) {
case _Transit():
return $default(_that.id,_that.transitingPlanet,_that.natalPlanet,_that.aspectType,_that.orb,_that.direction,_that.house,_that.peakTime,_that.windowStart,_that.windowEnd,_that.transitingLongitude,_that.natalLongitude,_that.isRetrograde,_that.phase,_that.priorityScore,_that.isMajor,_that.headline,_that.hook,_that.readingPreview,_that.readingFull,_that.transitingPlanetMeaning,_that.natalPlanetMeaning,_that.houseMeaning);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Planet transitingPlanet,  Planet natalPlanet,  AspectType aspectType,  double orb,  AspectDirection direction,  House house,  DateTime peakTime,  DateTime windowStart,  DateTime windowEnd,  double transitingLongitude,  double natalLongitude,  bool isRetrograde,  TransitPhase phase,  int priorityScore,  bool isMajor,  String? headline,  String? hook,  String? readingPreview,  String? readingFull,  String? transitingPlanetMeaning,  String? natalPlanetMeaning,  String? houseMeaning)?  $default,) {final _that = this;
switch (_that) {
case _Transit() when $default != null:
return $default(_that.id,_that.transitingPlanet,_that.natalPlanet,_that.aspectType,_that.orb,_that.direction,_that.house,_that.peakTime,_that.windowStart,_that.windowEnd,_that.transitingLongitude,_that.natalLongitude,_that.isRetrograde,_that.phase,_that.priorityScore,_that.isMajor,_that.headline,_that.hook,_that.readingPreview,_that.readingFull,_that.transitingPlanetMeaning,_that.natalPlanetMeaning,_that.houseMeaning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transit extends Transit {
  const _Transit({required this.id, required this.transitingPlanet, required this.natalPlanet, required this.aspectType, required this.orb, required this.direction, required this.house, required this.peakTime, required this.windowStart, required this.windowEnd, required this.transitingLongitude, required this.natalLongitude, this.isRetrograde = false, this.phase = TransitPhase.active, this.priorityScore = 0, this.isMajor = false, this.headline, this.hook, this.readingPreview, this.readingFull, this.transitingPlanetMeaning, this.natalPlanetMeaning, this.houseMeaning}): super._();
  factory _Transit.fromJson(Map<String, dynamic> json) => _$TransitFromJson(json);

@override final  String id;
@override final  Planet transitingPlanet;
@override final  Planet natalPlanet;
@override final  AspectType aspectType;
/// How close to exact the aspect is (degrees). 0 = perfect.
@override final  double orb;
@override final  AspectDirection direction;
/// Which natal house the transiting planet occupies.
@override final  House house;
/// When the orb reaches its minimum (maximum intensity).
@override final  DateTime peakTime;
/// When the transit entered orb tolerance.
@override final  DateTime windowStart;
/// When the transit will leave orb tolerance.
@override final  DateTime windowEnd;
@override final  double transitingLongitude;
@override final  double natalLongitude;
/// Whether the transiting planet is currently retrograde.
@override@JsonKey() final  bool isRetrograde;
// New fields for river UI
@override@JsonKey() final  TransitPhase phase;
@override@JsonKey() final  int priorityScore;
@override@JsonKey() final  bool isMajor;
// Content fields (populated by reading bank or AI)
@override final  String? headline;
@override final  String? hook;
@override final  String? readingPreview;
@override final  String? readingFull;
// Meaning fields (for equation display)
@override final  String? transitingPlanetMeaning;
@override final  String? natalPlanetMeaning;
@override final  String? houseMeaning;

/// Create a copy of Transit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransitCopyWith<_Transit> get copyWith => __$TransitCopyWithImpl<_Transit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transit&&(identical(other.id, id) || other.id == id)&&(identical(other.transitingPlanet, transitingPlanet) || other.transitingPlanet == transitingPlanet)&&(identical(other.natalPlanet, natalPlanet) || other.natalPlanet == natalPlanet)&&(identical(other.aspectType, aspectType) || other.aspectType == aspectType)&&(identical(other.orb, orb) || other.orb == orb)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.house, house) || other.house == house)&&(identical(other.peakTime, peakTime) || other.peakTime == peakTime)&&(identical(other.windowStart, windowStart) || other.windowStart == windowStart)&&(identical(other.windowEnd, windowEnd) || other.windowEnd == windowEnd)&&(identical(other.transitingLongitude, transitingLongitude) || other.transitingLongitude == transitingLongitude)&&(identical(other.natalLongitude, natalLongitude) || other.natalLongitude == natalLongitude)&&(identical(other.isRetrograde, isRetrograde) || other.isRetrograde == isRetrograde)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.priorityScore, priorityScore) || other.priorityScore == priorityScore)&&(identical(other.isMajor, isMajor) || other.isMajor == isMajor)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.hook, hook) || other.hook == hook)&&(identical(other.readingPreview, readingPreview) || other.readingPreview == readingPreview)&&(identical(other.readingFull, readingFull) || other.readingFull == readingFull)&&(identical(other.transitingPlanetMeaning, transitingPlanetMeaning) || other.transitingPlanetMeaning == transitingPlanetMeaning)&&(identical(other.natalPlanetMeaning, natalPlanetMeaning) || other.natalPlanetMeaning == natalPlanetMeaning)&&(identical(other.houseMeaning, houseMeaning) || other.houseMeaning == houseMeaning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,transitingPlanet,natalPlanet,aspectType,orb,direction,house,peakTime,windowStart,windowEnd,transitingLongitude,natalLongitude,isRetrograde,phase,priorityScore,isMajor,headline,hook,readingPreview,readingFull,transitingPlanetMeaning,natalPlanetMeaning,houseMeaning]);

@override
String toString() {
  return 'Transit(id: $id, transitingPlanet: $transitingPlanet, natalPlanet: $natalPlanet, aspectType: $aspectType, orb: $orb, direction: $direction, house: $house, peakTime: $peakTime, windowStart: $windowStart, windowEnd: $windowEnd, transitingLongitude: $transitingLongitude, natalLongitude: $natalLongitude, isRetrograde: $isRetrograde, phase: $phase, priorityScore: $priorityScore, isMajor: $isMajor, headline: $headline, hook: $hook, readingPreview: $readingPreview, readingFull: $readingFull, transitingPlanetMeaning: $transitingPlanetMeaning, natalPlanetMeaning: $natalPlanetMeaning, houseMeaning: $houseMeaning)';
}


}

/// @nodoc
abstract mixin class _$TransitCopyWith<$Res> implements $TransitCopyWith<$Res> {
  factory _$TransitCopyWith(_Transit value, $Res Function(_Transit) _then) = __$TransitCopyWithImpl;
@override @useResult
$Res call({
 String id, Planet transitingPlanet, Planet natalPlanet, AspectType aspectType, double orb, AspectDirection direction, House house, DateTime peakTime, DateTime windowStart, DateTime windowEnd, double transitingLongitude, double natalLongitude, bool isRetrograde, TransitPhase phase, int priorityScore, bool isMajor, String? headline, String? hook, String? readingPreview, String? readingFull, String? transitingPlanetMeaning, String? natalPlanetMeaning, String? houseMeaning
});




}
/// @nodoc
class __$TransitCopyWithImpl<$Res>
    implements _$TransitCopyWith<$Res> {
  __$TransitCopyWithImpl(this._self, this._then);

  final _Transit _self;
  final $Res Function(_Transit) _then;

/// Create a copy of Transit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? transitingPlanet = null,Object? natalPlanet = null,Object? aspectType = null,Object? orb = null,Object? direction = null,Object? house = null,Object? peakTime = null,Object? windowStart = null,Object? windowEnd = null,Object? transitingLongitude = null,Object? natalLongitude = null,Object? isRetrograde = null,Object? phase = null,Object? priorityScore = null,Object? isMajor = null,Object? headline = freezed,Object? hook = freezed,Object? readingPreview = freezed,Object? readingFull = freezed,Object? transitingPlanetMeaning = freezed,Object? natalPlanetMeaning = freezed,Object? houseMeaning = freezed,}) {
  return _then(_Transit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transitingPlanet: null == transitingPlanet ? _self.transitingPlanet : transitingPlanet // ignore: cast_nullable_to_non_nullable
as Planet,natalPlanet: null == natalPlanet ? _self.natalPlanet : natalPlanet // ignore: cast_nullable_to_non_nullable
as Planet,aspectType: null == aspectType ? _self.aspectType : aspectType // ignore: cast_nullable_to_non_nullable
as AspectType,orb: null == orb ? _self.orb : orb // ignore: cast_nullable_to_non_nullable
as double,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as AspectDirection,house: null == house ? _self.house : house // ignore: cast_nullable_to_non_nullable
as House,peakTime: null == peakTime ? _self.peakTime : peakTime // ignore: cast_nullable_to_non_nullable
as DateTime,windowStart: null == windowStart ? _self.windowStart : windowStart // ignore: cast_nullable_to_non_nullable
as DateTime,windowEnd: null == windowEnd ? _self.windowEnd : windowEnd // ignore: cast_nullable_to_non_nullable
as DateTime,transitingLongitude: null == transitingLongitude ? _self.transitingLongitude : transitingLongitude // ignore: cast_nullable_to_non_nullable
as double,natalLongitude: null == natalLongitude ? _self.natalLongitude : natalLongitude // ignore: cast_nullable_to_non_nullable
as double,isRetrograde: null == isRetrograde ? _self.isRetrograde : isRetrograde // ignore: cast_nullable_to_non_nullable
as bool,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as TransitPhase,priorityScore: null == priorityScore ? _self.priorityScore : priorityScore // ignore: cast_nullable_to_non_nullable
as int,isMajor: null == isMajor ? _self.isMajor : isMajor // ignore: cast_nullable_to_non_nullable
as bool,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,hook: freezed == hook ? _self.hook : hook // ignore: cast_nullable_to_non_nullable
as String?,readingPreview: freezed == readingPreview ? _self.readingPreview : readingPreview // ignore: cast_nullable_to_non_nullable
as String?,readingFull: freezed == readingFull ? _self.readingFull : readingFull // ignore: cast_nullable_to_non_nullable
as String?,transitingPlanetMeaning: freezed == transitingPlanetMeaning ? _self.transitingPlanetMeaning : transitingPlanetMeaning // ignore: cast_nullable_to_non_nullable
as String?,natalPlanetMeaning: freezed == natalPlanetMeaning ? _self.natalPlanetMeaning : natalPlanetMeaning // ignore: cast_nullable_to_non_nullable
as String?,houseMeaning: freezed == houseMeaning ? _self.houseMeaning : houseMeaning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
