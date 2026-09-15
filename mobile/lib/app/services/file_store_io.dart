import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String> savePdfBytes(Uint8List bytes, String filename) async {
  final locations = <Directory>[];
  try {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) locations.add(downloads);
  } catch (_) {}
  locations.add(await getApplicationDocumentsDirectory());

  Object? lastError;
  for (final dir in locations) {
    try {
      final file = File('${dir.path}${Platform.pathSeparator}$filename');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError ?? Exception('Unable to save the PDF.');
}

Future<String?> writeTempPdf(Uint8List bytes, String filename) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}${Platform.pathSeparator}$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
