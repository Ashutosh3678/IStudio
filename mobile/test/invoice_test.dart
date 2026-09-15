import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_studio/app/models/invoice.dart';
import 'package:lumen_studio/app/providers/invoices_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Invoice _invoice({
  String id = 'inv-1',
  String number = 'INV-2001',
  DateTime? dueDate,
  double received = 0,
  List<InvoiceDeliverable>? deliverables,
}) {
  return Invoice(
    id: id,
    number: number,
    eventName: 'Wedding — Test',
    contactName: 'Aanya Sharma',
    phone: '9876543210',
    address: 'Mumbai',
    issuedOn: DateTime(2026, 8, 1),
    dueDate: dueDate ?? DateTime(2026, 12, 31),
    upiId: 'studio@okaxis',
    amountReceived: received,
    deliverables: deliverables ??
        const [
          InvoiceDeliverable(id: 'd1', name: 'Coverage', cost: 50000),
          InvoiceDeliverable(id: 'd2', name: 'Album', cost: 20000),
        ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Invoice model', () {
    test('sums deliverable costs and remaining balance', () {
      final invoice = _invoice(received: 20000);
      expect(invoice.total, 70000);
      expect(invoice.pendingAmount, 50000);
      expect(invoice.isPartiallyPaid, isTrue);
      expect(invoice.status, InvoiceStatus.partial);
    });

    test('marks paid invoices when received covers the total', () {
      final invoice = _invoice(received: 70000);
      expect(invoice.isPaid, isTrue);
      expect(invoice.pendingAmount, 0);
      expect(invoice.status, InvoiceStatus.paid);
    });

    test('marks unpaid future invoices as pending', () {
      final invoice = _invoice(
        dueDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(invoice.status, InvoiceStatus.pending);
      expect(invoice.isOverdue, isFalse);
    });

    test('marks past-due unpaid invoices as overdue', () {
      final invoice = _invoice(
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        received: 10000,
      );
      expect(invoice.isOverdue, isTrue);
      expect(invoice.isPartiallyPaid, isTrue);
      expect(invoice.status, InvoiceStatus.overdue);
    });

    test('serializes and restores invoice fields', () {
      final original = _invoice();
      final restored = Invoice.fromJson(original.toJson());
      expect(restored.number, original.number);
      expect(restored.contactName, original.contactName);
      expect(restored.deliverables.length, 2);
      expect(restored.total, original.total);
      expect(restored.upiId, 'studio@okaxis');
    });

    test('parses API invoice payloads that include computed fields', () {
      final invoice = Invoice.fromJson({
        'id': '64f1ab',
        'number': 'INV-1102',
        'eventName': 'Wedding — Test',
        'contactName': 'Aanya Sharma',
        'phone': '9876543210',
        'address': 'Mumbai',
        'issuedOn': '2026-08-01T00:00:00.000Z',
        'dueDate': '2026-12-31T00:00:00.000Z',
        'upiId': 'studio@okaxis',
        'amountReceived': 10000,
        'total': 70000,
        'pendingAmount': 60000,
        'status': 'partial',
        'deliverables': [
          {'id': 'd1', 'name': 'Coverage', 'cost': 50000},
          {'id': 'd2', 'name': 'Album', 'cost': 20000},
        ],
      });

      expect(invoice.id, '64f1ab');
      expect(invoice.number, 'INV-1102');
      expect(invoice.total, 70000);
      expect(invoice.pendingAmount, 60000);
      expect(invoice.status, InvoiceStatus.partial);
    });
  });

  group('InvoicesProvider', () {
    test('filters paid, pending, partial and overdue invoices', () async {
      SharedPreferences.setMockInitialValues({'lumen_invoices_v1': '[]'});
      final provider = InvoicesProvider();
      await provider.bootstrap();

      await provider.addInvoice(
        _invoice(
          id: 'paid',
          number: 'INV-1',
          received: 70000,
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
      );
      await provider.addInvoice(
        _invoice(
          id: 'pending',
          number: 'INV-2',
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
      );
      await provider.addInvoice(
        _invoice(
          id: 'partial',
          number: 'INV-3',
          received: 10000,
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
      );
      await provider.addInvoice(
        _invoice(
          id: 'overdue',
          number: 'INV-4',
          received: 5000,
          dueDate: DateTime.now().subtract(const Duration(days: 4)),
        ),
      );

      expect(provider.filtered(InvoiceFilter.all).length, 4);
      expect(provider.filtered(InvoiceFilter.paid).single.id, 'paid');
      expect(provider.filtered(InvoiceFilter.pending).single.id, 'pending');
      expect(provider.filtered(InvoiceFilter.partial).map((i) => i.id),
          containsAll(['partial', 'overdue']));
      expect(provider.filtered(InvoiceFilter.overdue).single.id, 'overdue');
    });

    test('updates payment state and due dates from history actions', () async {
      SharedPreferences.setMockInitialValues({'lumen_invoices_v1': '[]'});
      final provider = InvoicesProvider();
      await provider.bootstrap();
      await provider.addInvoice(
        _invoice(
          id: 'act',
          number: 'INV-9',
          dueDate: DateTime.now().add(const Duration(days: 2)),
        ),
      );

      await provider.markPartiallyPaid('act', 20000);
      expect(provider.getById('act')!.amountReceived, 20000);
      expect(provider.getById('act')!.status, InvoiceStatus.partial);

      final nextDue = DateTime.now().add(const Duration(days: 20));
      await provider.extendDueDate('act', nextDue);
      expect(provider.getById('act')!.dueDate.day, nextDue.day);

      await provider.markAsPaid('act');
      expect(provider.getById('act')!.isPaid, isTrue);

      final overview = provider.overview;
      expect(overview.total, 70000);
      expect(overview.received, 70000);
      expect(overview.pending, 0);

      await provider.deleteInvoice('act');
      expect(provider.invoices, isEmpty);
    });

    test('increments invoice numbers from existing records', () async {
      SharedPreferences.setMockInitialValues({'lumen_invoices_v1': '[]'});
      final provider = InvoicesProvider();
      await provider.bootstrap();
      await provider.addInvoice(_invoice(id: 'a', number: 'INV-1042'));
      expect(provider.nextNumber(), 'INV-1043');
    });
  });
}
