class StudioSession {
  const StudioSession({
    required this.id,
    required this.title,
    required this.clientName,
    required this.startsAt,
    required this.location,
  });

  final String id;
  final String title;
  final String clientName;
  final DateTime startsAt;
  final String location;
}
