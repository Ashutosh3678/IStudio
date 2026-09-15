import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/invoice.dart';
import '../services/api_service.dart';
import '../services/invoice_service.dart';
import 'auth_provider.dart';

class InvoicesProvider extends ChangeNotifier {
  InvoicesProvider({InvoiceService? invoiceService})
    : _invoiceService = invoiceService ?? InvoiceService();

  static const _storageKey = 'lumen_invoices_v1';
  static const _upiKey = 'lumen_last_upi';

  final InvoiceService _invoiceService;
  final List<Invoice> _invoices = [];
  String _lastUpiId = '';
  String? _token;
  String? _errorMessage;
  bool _ready = false;
  bool _loading = false;

  List<Invoice> get invoices => List.unmodifiable(_invoices);
  String get lastUpiId => _lastUpiId;
  String? get errorMessage => _errorMessage;
  bool get isReady => _ready;
  bool get _useApi => _token != null && _token!.isNotEmpty;

  InvoiceOverview get overview {
    var total = 0.0;
    var received = 0.0;
    for (final invoice in _invoices) {
      total += invoice.total;
      received += invoice.amountReceived.clamp(0, invoice.total);
    }
    return InvoiceOverview(
      total: total,
      received: received,
      pending: (total - received).clamp(0, double.infinity),
    );
  }

  List<Invoice> filtered(InvoiceFilter filter) {
    final items = _invoices.where((invoice) {
      switch (filter) {
        case InvoiceFilter.all:
          return true;
        case InvoiceFilter.paid:
          return invoice.status == InvoiceStatus.paid;
        case InvoiceFilter.pending:
          return invoice.status == InvoiceStatus.pending;
        case InvoiceFilter.partial:
          return invoice.isPartiallyPaid;
        case InvoiceFilter.overdue:
          return invoice.isOverdue;
      }
    }).toList();
    items.sort((a, b) => b.issuedOn.compareTo(a.issuedOn));
    return items;
  }

  Invoice? getById(String id) {
    for (final invoice in _invoices) {
      if (invoice.id == id) return invoice;
    }
    return null;
  }

  String nextNumber() {
    var max = 1000;
    final pattern = RegExp(r'INV-(\d+)', caseSensitive: false);
    for (final invoice in _invoices) {
      final match = pattern.firstMatch(invoice.number);
      if (match == null) continue;
      final value = int.tryParse(match.group(1) ?? '') ?? 0;
      if (value > max) max = value;
    }
    return 'INV-${max + 1}';
  }

  void syncAuth(AuthProvider auth) {
    if (auth.isBootstrapping) return;
    final token = auth.token;
    if (token == _token && (_ready || _loading)) return;
    _token = token;
    if (!_useApi) {
      _invoices.clear();
      _loading = false;
      _ready = true;
      notifyListeners();
      return;
    }
    _ready = false;
    notifyListeners();
    loadRemote();
  }

  Future<void> bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastUpiId = prefs.getString(_upiKey) ?? '';
      if (_useApi) {
        await loadRemote();
        return;
      }
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _invoices
            ..clear()
            ..addAll(
              decoded.whereType<Map>().map(
                (item) => Invoice.fromJson(Map<String, dynamic>.from(item)),
              ),
            );
        }
      }
    } catch (_) {
      _errorMessage = 'Unable to load invoices.';
    } finally {
      _ready = true;
      notifyListeners();
    }
  }

  Future<void> loadRemote() async {
    if (!_useApi) return;
    _loading = true;
    _errorMessage = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastUpiId = prefs.getString(_upiKey) ?? _lastUpiId;
      final invoices = await _invoiceService.list(token: _token!);
      _invoices
        ..clear()
        ..addAll(invoices);
      _preferLatestUpi();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load invoices.';
    } finally {
      _loading = false;
      _ready = true;
      notifyListeners();
    }
  }

  Future<Invoice> addInvoice(Invoice invoice) async {
    final stored = invoice.number.trim().isEmpty
        ? invoice.copyWith(number: nextNumber())
        : invoice;

    if (_useApi) {
      final created = await _invoiceService.create(
        token: _token!,
        invoice: stored,
      );
      _invoices.insert(0, created);
      _rememberUpiMemory(created.upiId);
      notifyListeners();
      return created;
    }

    _invoices.insert(0, stored);
    _rememberUpiMemory(stored.upiId);
    await _persist();
    notifyListeners();
    return stored;
  }

  Future<void> updateInvoice(Invoice invoice) async {
    _replace(invoice);
    if (!_useApi) await _persist();
    notifyListeners();
  }

  Future<void> deleteInvoice(String id) async {
    if (_useApi) {
      await _invoiceService.delete(token: _token!, id: id);
    }
    _invoices.removeWhere((item) => item.id == id);
    if (!_useApi) await _persist();
    notifyListeners();
  }

  Future<void> markAsPaid(String id) async {
    if (_useApi) {
      final updated = await _invoiceService.markPaid(token: _token!, id: id);
      _replace(updated);
      notifyListeners();
      return;
    }
    final invoice = getById(id);
    if (invoice == null) return;
    await updateInvoice(invoice.copyWith(amountReceived: invoice.total));
  }

  Future<void> markPartiallyPaid(String id, double amount) async {
    if (_useApi) {
      final updated = await _invoiceService.markPartial(
        token: _token!,
        id: id,
        amount: amount,
      );
      _replace(updated);
      notifyListeners();
      return;
    }
    final invoice = getById(id);
    if (invoice == null || amount <= 0) return;
    final next = (invoice.amountReceived + amount).clamp(0, invoice.total);
    await updateInvoice(invoice.copyWith(amountReceived: next.toDouble()));
  }

  Future<void> extendDueDate(String id, DateTime dueDate) async {
    if (_useApi) {
      final updated = await _invoiceService.extendDueDate(
        token: _token!,
        id: id,
        dueDate: dueDate,
      );
      _replace(updated);
      notifyListeners();
      return;
    }
    final invoice = getById(id);
    if (invoice == null) return;
    await updateInvoice(invoice.copyWith(dueDate: dueDate));
  }

  Future<void> rememberUpi(String upiId) async {
    final trimmed = upiId.trim();
    if (trimmed.isEmpty || trimmed == _lastUpiId) return;
    _lastUpiId = trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_upiKey, trimmed);
  }

  void _replace(Invoice invoice) {
    final index = _invoices.indexWhere((item) => item.id == invoice.id);
    if (index == -1) {
      _invoices.insert(0, invoice);
    } else {
      _invoices[index] = invoice;
    }
  }

  void _rememberUpiMemory(String upiId) {
    final trimmed = upiId.trim();
    if (trimmed.isNotEmpty) _lastUpiId = trimmed;
  }

  void _preferLatestUpi() {
    if (_lastUpiId.isNotEmpty) return;
    for (final invoice in _invoices) {
      if (invoice.upiId.trim().isEmpty) continue;
      _lastUpiId = invoice.upiId.trim();
      return;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_invoices.map((item) => item.toJson()).toList()),
    );
    if (_lastUpiId.isNotEmpty) {
      await prefs.setString(_upiKey, _lastUpiId);
    }
  }
}
