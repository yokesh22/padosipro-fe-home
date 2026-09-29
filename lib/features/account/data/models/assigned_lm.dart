/// The Lifestyle Manager assigned to the user.
class AssignedLm {
  const AssignedLm({required this.name, required this.city});

  final String name;
  final String city;

  /// Everyone gets the pilot LM until the API assigns one.
  static const pilot = AssignedLm(name: 'Pilot LM', city: 'Mumbai');
}
