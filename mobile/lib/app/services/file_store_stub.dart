import 'dart:typed_data';

Future<String> savePdfBytes(Uint8List bytes, String filename) async {
  throw UnsupportedError('Saving PDFs is not supported on this platform.');
}

Future<String?> writeTempPdf(Uint8List bytes, String filename) async => null;
