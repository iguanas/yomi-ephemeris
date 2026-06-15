import 'package:uuid/uuid.dart';
import 'models/birth_chart.dart';
import 'models/geo_location.dart';
import 'models/house.dart';
import 'models/planet.dart';
import 'models/transit.dart';
import 'astronomy/house_calculator.dart';
import 'astronomy/planet_position.dart';
import 'astronomy/transit_finder.dart';

const _uuid = Uuid();

/// Public API for all astronomy calculations.
class AstronomyService {
  final HouseCalculator _houseCalc = HouseCalculator();
  final TransitFinder _transitFinder = TransitFinder();

  /// Calculate a complete birth chart from birth data.
  ///
  /// [exactTimeKnown] is a fact about the input, not the computation: pass
  /// `true` only when the birth time is genuinely known. Downstream
  /// consumers suppress Rising/house claims when it is `false`
  /// (noon-default charts), so leaving it unset on a known-time chart
  /// silently downgrades every house-sensitive output.
  BirthChart calculateBirthChart(
    DateTime birthDateTime,
    GeoLocation location, {
    bool exactTimeKnown = false,
  }) {
    final utc = birthDateTime.toUtc();
    final positions = allPlanetPositions(utc);
    final cusps = _houseCalc.calculateCusps(utc, location);

    return BirthChart(
      id: _uuid.v4(),
      birthDateTime: utc,
      birthLocation: location,
      planetPositions: positions,
      houseCusps: cusps,
      exactTimeKnown: exactTimeKnown,
      engineVersion: currentEngineVersion,
      calculatedAt: DateTime.now().toUtc(),
    );
  }

  /// Get all active transits against [chart] right now.
  List<Transit> getCurrentTransits(BirthChart chart) {
    return _transitFinder.findActiveTransits(chart, DateTime.now().toUtc());
  }

  /// Pick the featured transit:
  /// 1. Tightest Moon transit (if any Moon aspects are active)
  /// 2. Tightest transit overall (if no Moon aspects)
  Transit? getFeaturedTransit(List<Transit> transits) {
    if (transits.isEmpty) return null;

    // Already sorted by orb (tightest first).
    final moonTransits = transits
        .where((t) => t.transitingPlanet == Planet.moon)
        .toList();

    return moonTransits.isNotEmpty ? moonTransits.first : transits.first;
  }

  /// Picks the Moon transit whose peak is closest to now.
  /// Returns null if no Moon transits are active.
  Transit? getMoonReading(List<Transit> transits) {
    final moonTransits = transits
        .where((t) => t.transitingPlanet == Planet.moon)
        .toList();
    if (moonTransits.isEmpty) return null;
    final now = DateTime.now().toUtc();
    moonTransits.sort((a, b) =>
      a.peakTime.difference(now).abs().compareTo(
      b.peakTime.difference(now).abs()));
    return moonTransits.first;
  }

  /// Group transits by the natal house they activate.
  Map<House, List<Transit>> groupTransitsByHouse(List<Transit> transits) {
    final grouped = <House, List<Transit>>{};
    for (final transit in transits) {
      grouped.putIfAbsent(transit.house, () => []).add(transit);
    }
    return grouped;
  }

  /// How long until the transit peaks.
  Duration timeUntilPeak(Transit transit) {
    return transit.peakTime.difference(DateTime.now().toUtc());
  }

  /// Calculate ascendant for a birth time and location.
  double getAscendant(DateTime birthDateTime, GeoLocation location) {
    return _houseCalc.ascendant(birthDateTime.toUtc(), location);
  }
}
