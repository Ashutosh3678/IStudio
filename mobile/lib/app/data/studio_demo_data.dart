import '../models/studio_session.dart';

class StudioDemoData {
  const StudioDemoData._();

  static final List<StudioSession> sessions = [
    StudioSession(
      id: 's1',
      title: 'Wedding preview',
      clientName: 'Aanya & Rohan',
      startsAt: DateTime.now().add(const Duration(days: 1, hours: 2)),
      location: 'Lotus Pavilion',
    ),
    StudioSession(
      id: 's2',
      title: 'Maternity session',
      clientName: 'Meera Kapoor',
      startsAt: DateTime.now().add(const Duration(days: 3)),
      location: 'Studio floor B',
    ),
    StudioSession(
      id: 's3',
      title: 'Brand campaign',
      clientName: 'Northwind Atelier',
      startsAt: DateTime.now().add(const Duration(days: 6, hours: 4)),
      location: 'City terrace',
    ),
    StudioSession(
      id: 's4',
      title: 'Newborn session',
      clientName: 'The Iyer family',
      startsAt: DateTime.now().add(const Duration(days: 10)),
      location: 'Softbox suite',
    ),
  ];

  static const clients = [
    ('Aanya Sharma', 'Wedding'),
    ('Meera Kapoor', 'Maternity'),
    ('Northwind Atelier', 'Commercial'),
    ('Iyer family', 'Newborn'),
  ];
}
