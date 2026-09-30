import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/invoice.dart';
import '../models/user.dart';
import 'api_config.dart';
import 'file_store.dart';

/// Single PDF pipeline used by estimates, invoices, and receipts.
class InvoicePdfService {
  const InvoicePdfService._();

  static final _money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs. ',
    decimalDigits: 2,
  );
  static final _date = DateFormat('d MMMM yyyy');

  static const _ink = PdfColor.fromInt(0xFF0B1320);
  static const _navy = PdfColor.fromInt(0xFF1C2541);
  static const _blue = PdfColor.fromInt(0xFF3A506B);
  static const _aqua = PdfColor.fromInt(0xFF5BC0BE);
  static const _paper = PdfColor.fromInt(0xFFF4F7F5);
  static const _muted = PdfColor.fromInt(0xFF64748B);
  static const _line = PdfColor.fromInt(0xFFD7DEE8);

  static String fileName(Invoice invoice, {User? studio}) {
    final studioName = _safeFilename(_firstNonEmpty([
      studio?.studioName,
      studio?.ownerName,
      studio?.username,
      'Studio',
    ]));
    final number = _safeFilename(invoice.number.trim().isEmpty
        ? 'document'
        : invoice.number);
    return '${studioName}_$number.pdf';
  }

  static Future<Uint8List> buildBytes({
    required Invoice invoice,
    User? studio,
  }) async {
    Uint8List? logoBytes;
    final logoUrl = studio?.logoUrl.trim() ?? '';
    if (logoUrl.isNotEmpty) {
      final resolvedLogo = ApiConfig.resolveMedia(logoUrl);
      if (resolvedLogo.startsWith('http://') ||
          resolvedLogo.startsWith('https://')) {
        try {
          final response = await http.get(Uri.parse(resolvedLogo));
          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            logoBytes = response.bodyBytes;
          }
        } catch (_) {
          // The PDF still renders with the monogram fallback.
        }
      }
    }

    return compute(
      _generatePdfBytes,
      _PdfParams(invoice: invoice, studio: studio, logoBytes: logoBytes),
    );
  }

  static Future<Uint8List> _generatePdfBytes(_PdfParams params) async {
    final invoice = params.invoice;
    final studio = params.studio;
    final studioName = _firstNonEmpty([
      studio?.studioName,
      studio?.ownerName,
      studio?.username,
    ]);
    final address = _joinNonEmpty([studio?.address, studio?.city]);
    final logo = params.logoBytes == null
        ? null
        : pw.MemoryImage(params.logoBytes!);
    final kind = _documentKind(invoice);
    final title = switch (kind) {
      _DocumentKind.estimate => 'ESTIMATED COST',
      _DocumentKind.invoice => 'INVOICE',
      _DocumentKind.receipt => 'PAYMENT RECEIPT',
    };
    final subtitle = switch (kind) {
      _DocumentKind.estimate => 'PROJECT SUMMARY',
      _DocumentKind.invoice => 'PAYMENT STATEMENT',
      _DocumentKind.receipt => 'PAYMENT CONFIRMATION',
    };

    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(38, 34, 38, 42),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 14),
          padding: const pw.EdgeInsets.only(top: 9),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _line, width: 0.7)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  studioName.isEmpty ? 'Thank you for choosing us.' : 'Thank you for choosing $studioName.',
                  style: const pw.TextStyle(color: _muted, fontSize: 8.5),
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(color: _muted, fontSize: 8.5),
              ),
            ],
          ),
        ),
        build: (context) => [
          _header(
            studio: studio,
            studioName: studioName,
            address: address,
            logo: logo,
            title: title,
            subtitle: subtitle,
            invoice: invoice,
          ),
          pw.SizedBox(height: 22),
          _sectionLabel('CLIENT & DOCUMENT DETAILS'),
          pw.SizedBox(height: 8),
          _details(invoice),
          pw.SizedBox(height: 20),
          _sectionLabel('PROJECT SUMMARY'),
          pw.SizedBox(height: 8),
          _projectSummary(invoice),
          pw.SizedBox(height: 20),
          _sectionLabel('DELIVERABLES'),
          pw.SizedBox(height: 8),
          _itemsTable(invoice),
          pw.SizedBox(height: 16),
          _totals(invoice),
          if (!invoice.isEstimate && invoice.upiId.trim().isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _payment(invoice),
          ],
          pw.SizedBox(height: 18),
          _socialSection(studio),
          pw.SizedBox(height: 16),
          _terms(invoice),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _header({
    required User? studio,
    required String studioName,
    required String address,
    required pw.ImageProvider? logo,
    required String title,
    required String subtitle,
    required Invoice invoice,
  }) {
    final contact = _joinNonEmpty([
      studio?.phone,
      studio?.email,
      address,
    ]);
    final specialties = studio?.specialties.trim() ?? '';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _logoBox(logo, studioName),
            pw.SizedBox(width: 14),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (studioName.isNotEmpty)
                    pw.Text(
                      studioName,
                      style: pw.TextStyle(
                        color: _ink,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  if (specialties.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      specialties.toUpperCase(),
                      style: pw.TextStyle(
                        color: _aqua,
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                  if (contact.isNotEmpty) ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      contact,
                      style: const pw.TextStyle(color: _muted, fontSize: 8.5),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(width: 14),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    color: _navy,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  subtitle,
                  style: const pw.TextStyle(color: _muted, fontSize: 8.5),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  invoice.number,
                  style: pw.TextStyle(
                    color: _ink,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Container(height: 2, color: _aqua),
        pw.SizedBox(height: 2),
        pw.Container(height: 0.7, color: _line),
      ],
    );
  }

  static pw.Widget _logoBox(pw.ImageProvider? logo, String studioName) {
    if (logo != null) {
      return pw.Container(
        width: 54,
        height: 54,
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: _line),
        ),
        child: pw.ClipRRect(
          horizontalRadius: 8,
          verticalRadius: 8,
          child: pw.Image(logo, fit: pw.BoxFit.cover),
        ),
      );
    }
    final initial = studioName.isEmpty ? 'S' : studioName.substring(0, 1).toUpperCase();
    return pw.Container(
      width: 54,
      height: 54,
      decoration: pw.BoxDecoration(
        color: _paper,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _aqua, width: 1.2),
      ),
      child: pw.Center(
        child: pw.Text(
          initial,
          style: pw.TextStyle(
            color: _navy,
            fontSize: 23,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static pw.Widget _details(Invoice invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _infoBlock('CLIENT', [
            invoice.contactName,
            invoice.phone,
            invoice.address,
          ]),
        ),
        pw.SizedBox(width: 18),
        pw.Expanded(
          child: _infoBlock('DOCUMENT', [
            '${_documentLabel(invoice)} date: ${_date.format(invoice.issuedOn)}',
            '${invoice.isEstimate ? 'Valid until' : 'Due date'}: ${_date.format(invoice.dueDate)}',
            '${invoice.deliverables.length} deliverable${invoice.deliverables.length == 1 ? '' : 's'}',
          ]),
        ),
      ],
    );
  }

  static pw.Widget _projectSummary(Invoice invoice) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: pw.BoxDecoration(
        color: _paper,
        border: pw.Border.all(color: _line),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _miniField('EVENT / PROJECT', invoice.eventName)),
          pw.SizedBox(width: 18),
          pw.Expanded(child: _miniField('DELIVERABLES', '${invoice.deliverables.length} item${invoice.deliverables.length == 1 ? '' : 's'}')),
        ],
      ),
    );
  }

  static pw.Widget _infoBlock(String label, List<String?> values) {
    final visible = values
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        pw.SizedBox(height: 6),
        ...visible.map(
          (value) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text(value, style: const pw.TextStyle(color: _muted, fontSize: 9.5)),
          ),
        ),
      ],
    );
  }

  static pw.Widget _miniField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(color: _blue, fontSize: 7.5, fontWeight: pw.FontWeight.bold, letterSpacing: 0.7)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(color: _ink, fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _itemsTable(Invoice invoice) {
    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _navy),
        children: [_th('#'), _th('Deliverable'), _th('Description'), _th('Amount', align: pw.TextAlign.right)],
      ),
      ...invoice.deliverables.asMap().entries.map((entry) {
        final item = entry.value;
        return pw.TableRow(
          decoration: pw.BoxDecoration(color: entry.key.isEven ? PdfColors.white : _paper),
          children: [
            _td('${entry.key + 1}'),
            _td(item.name),
            _td('-'),
            _td(_money.format(item.cost), align: pw.TextAlign.right),
          ],
        );
      }),
    ];
    return pw.Table(
      border: pw.TableBorder(
        top: const pw.BorderSide(color: _line, width: 0.6),
        bottom: const pw.BorderSide(color: _line, width: 0.6),
        horizontalInside: const pw.BorderSide(color: _line, width: 0.45),
      ),
      columnWidths: const {
        0: pw.FixedColumnWidth(25),
        1: pw.FlexColumnWidth(2.6),
        2: pw.FlexColumnWidth(3.8),
        3: pw.FlexColumnWidth(1.8),
      },
      children: rows,
    );
  }

  static pw.Widget _totals(Invoice invoice) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        padding: const pw.EdgeInsets.fromLTRB(14, 11, 14, 12),
        decoration: pw.BoxDecoration(
          color: _paper,
          border: pw.Border.all(color: _line),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            _totalRow('Subtotal', _money.format(invoice.total)),
            if (invoice.isEstimate) ...[
              pw.SizedBox(height: 6),
              pw.Container(height: 0.7, color: _line),
              pw.SizedBox(height: 7),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Estimated total', style: pw.TextStyle(color: _ink, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text(_money.format(invoice.total), style: pw.TextStyle(color: _navy, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ] else ...[
              _totalRow('Amount received', _money.format(invoice.amountReceived)),
              pw.SizedBox(height: 6),
              pw.Container(height: 0.7, color: _line),
              pw.SizedBox(height: 7),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Balance due', style: pw.TextStyle(color: _ink, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text(_money.format(invoice.pendingAmount), style: pw.TextStyle(color: _navy, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static pw.Widget _totalRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: _muted, fontSize: 9)),
          pw.Text(value, style: pw.TextStyle(color: _ink, fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _payment(Invoice invoice) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0x115BC0BE),
        border: pw.Border.all(color: _aqua, width: 0.8),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionLabel('PAYMENT METHOD'),
                pw.SizedBox(height: 5),
                pw.Text('UPI', style: pw.TextStyle(color: _ink, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text(invoice.upiId.trim(), style: pw.TextStyle(color: _navy, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 3),
                pw.Text('Mention ${invoice.number} in the payment remarks.', style: const pw.TextStyle(color: _muted, fontSize: 8.5)),
              ],
            ),
          ),
          pw.Text('Payment details', style: const pw.TextStyle(color: _muted, fontSize: 8.5)),
        ],
      ),
    );
  }

  static pw.Widget _socialSection(User? studio) {
    final links = <_SocialLink>[];
    _addSocial(links, 'Instagram', studio?.instagram, 'https://instagram.com/');
    _addSocial(links, 'YouTube', studio?.youtube, 'https://youtube.com/');
    _addSocial(links, 'Website', studio?.website, null);
    if (links.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionLabel('VIEW OUR WORK'),
        pw.SizedBox(height: 6),
        pw.Text('Explore our latest work:', style: const pw.TextStyle(color: _muted, fontSize: 9)),
        pw.SizedBox(height: 5),
        pw.Wrap(
          spacing: 16,
          runSpacing: 4,
          children: links.map((link) {
            return pw.UrlLink(
              destination: link.url,
              child: pw.Text('${link.label}: ${link.display}', style: pw.TextStyle(color: _blue, fontSize: 9, decoration: pw.TextDecoration.underline)),
            );
          }).toList(),
        ),
      ],
    );
  }

  static void _addSocial(List<_SocialLink> links, String label, String? value, String? prefix) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return;
    final url = raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : prefix == null
            ? 'https://$raw'
            : '$prefix${raw.replaceFirst('@', '')}';
    links.add(_SocialLink(label, raw, url));
  }

  static pw.Widget _terms(Invoice invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionLabel('TERMS & CONDITIONS'),
        pw.SizedBox(height: 5),
        pw.Text(
          invoice.isEstimate
              ? 'This estimated cost is a proposal based on the requirements known today. It is not proof of payment or a financial receipt. Final pricing may change if the scope, date, location, package, or add-ons change. The booking is confirmed only after client acceptance and confirmation through the existing booking and payment process.'
              : 'This is an estimated cost and may vary with final requirements. Advance payment confirms the booking. Remaining balance is payable before final delivery. Delivery timelines may vary by package and project scope.',
          style: const pw.TextStyle(color: _muted, fontSize: 8.2, lineSpacing: 2),
        ),
      ],
    );
  }

  static pw.Widget _sectionLabel(String text) {
    return pw.Text(text, style: pw.TextStyle(color: _aqua, fontSize: 8, fontWeight: pw.FontWeight.bold, letterSpacing: 1.1));
  }

  static pw.Widget _th(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      child: pw.Text(text, textAlign: align, style: pw.TextStyle(color: PdfColors.white, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _td(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      child: pw.Text(text, textAlign: align, style: const pw.TextStyle(color: _ink, fontSize: 8.8)),
    );
  }

  static _DocumentKind _documentKind(Invoice invoice) {
    if (invoice.isEstimate) return _DocumentKind.estimate;
    final number = invoice.number.toUpperCase();
    if (number.startsWith('EST')) return _DocumentKind.estimate;
    if (number.startsWith('REC')) return _DocumentKind.receipt;
    return _DocumentKind.invoice;
  }

  static String _documentLabel(Invoice invoice) {
    return switch (_documentKind(invoice)) {
      _DocumentKind.estimate => 'Estimate',
      _DocumentKind.invoice => 'Invoice',
      _DocumentKind.receipt => 'Receipt',
    };
  }

  static String documentTitle(Invoice invoice) => _documentLabel(invoice);

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final clean = value?.trim() ?? '';
      if (clean.isNotEmpty) return clean;
    }
    return '';
  }

  static String _joinNonEmpty(List<String?> values) {
    return values
        .map((value) => value?.trim() ?? '')
        .where((value) => value.isNotEmpty)
        .join('  |  ');
  }

  static String _safeFilename(String value) {
    final safe = value.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    return safe.isEmpty ? 'Studio' : safe;
  }

  static Future<String> saveToDevice({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: filename);
      return filename;
    }
    return savePdfBytes(bytes, filename);
  }

  static Future<void> shareInvoice({
    required Invoice invoice,
    User? studio,
    Uint8List? bytes,
  }) async {
    final data = bytes ?? await buildBytes(invoice: invoice, studio: studio);
    final name = fileName(invoice, studio: studio);
    final message = '${_documentLabel(invoice)} ${invoice.number} for ${invoice.contactName}';
    try {
      final tempPath = await writeTempPdf(data, name);
      final files = tempPath == null
          ? [XFile.fromData(data, mimeType: 'application/pdf', name: name)]
          : [XFile(tempPath, mimeType: 'application/pdf', name: name)];
      await SharePlus.instance.share(ShareParams(files: files, subject: name, text: message, fileNameOverrides: [name]));
    } catch (_) {
      await Printing.sharePdf(bytes: data, filename: name, subject: name, body: message);
    }
  }
}

enum _DocumentKind { estimate, invoice, receipt }

class _SocialLink {
  const _SocialLink(this.label, this.display, this.url);

  final String label;
  final String display;
  final String url;
}

class _PdfParams {
  const _PdfParams({required this.invoice, this.studio, this.logoBytes});

  final Invoice invoice;
  final User? studio;
  final Uint8List? logoBytes;
}
