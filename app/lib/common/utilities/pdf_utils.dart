import 'dart:io';

import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../module.dart';

Future<String> createPdf(MedicationWithGuidelines medication) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Center(child: pw.Text(medication.name));
      },
    ),
  );
  final dir = Platform.isAndroid
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();

  final file = File('${dir!.path}/${medication.name}.pdf');
  await file.writeAsBytes(await pdf.save());
  return file.path;
}

Future<void> sharePdf(MedicationWithGuidelines medication) async {
  final path = await createPdf(medication);
  await FlutterShare.shareFile(title: medication.name, filePath: path);
}
