/// Lifecycle phase of a transit.
enum TransitPhase {
  forming(displayName: 'Forming'),
  active(displayName: 'Active'),
  peaking(displayName: 'Peaking'),
  separating(displayName: 'Separating');

  const TransitPhase({required this.displayName});
  final String displayName;
}
