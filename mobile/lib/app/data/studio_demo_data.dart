import '../models/invoice.dart';
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

  static final List<Invoice> invoices = [
    Invoice(
      id: 'i1',
      number: 'INV-1042',
      clientName: 'Aanya & Rohan',
      amount: 85000,
      issuedOn: DateTime.now().subtract(const Duration(days: 4)),
      status: InvoiceStatus.due,
    ),
    Invoice(
      id: 'i2',
      number: 'INV-1038',
      clientName: 'Northwind Atelier',
      amount: 42000,
      issuedOn: DateTime.now().subtract(const Duration(days: 12)),
      status: InvoiceStatus.paid,
    ),
    Invoice(
      id: 'i3',
      number: 'INV-1045',
      clientName: 'Meera Kapoor',
      amount: 18000,
      issuedOn: DateTime.now().subtract(const Duration(days: 1)),
      status: InvoiceStatus.draft,
    ),
  ];

  static const clients = [
    ('Aanya Sharma', 'Wedding'),
    ('Meera Kapoor', 'Maternity'),
    ('Northwind Atelier', 'Commercial'),
    ('Iyer family', 'Newborn'),
  ];
}
