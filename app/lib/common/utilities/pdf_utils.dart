import 'dart:io';

import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

import '../module.dart';

Future<String> createPdf(MedicationWithGuidelines medication) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [buildPdfPage(context, medication)],
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

pw.Widget buildPdfPage(
  pw.Context context,
  MedicationWithGuidelines medication,
) {
  final relevantGuidelines = filterUserGuidelines(medication).guidelines;
  return pw.Wrap(
    children: [
      _PdfSegment(
        child: pw.Text(
          medication.name,
          style: pw.TextStyle(fontSize: 26),
        ),
      ),
      if (medication.drugclass.isNotNullOrBlank)
        _PdfSegment(
          child: pw.Text(
            medication.drugclass!,
            style: pw.TextStyle(fontSize: 16),
          ),
        ),
      if (medication.description.isNotNullOrBlank)
        _PdfSegment(
          child: pw.Text(
            medication.description!,
            style: pw.TextStyle(fontSize: 12),
          ),
        ),
      pw.SizedBox(height: 16),
      for (final guideline in relevantGuidelines) ...[
        ..._buildGuidelinePart(guideline),
        pw.Divider(color: PdfColors.grey100),
        ..._buildGuidelinePart(guideline),
        ..._buildGuidelinePart(guideline)
      ]
    ],
  );
}

List<pw.Widget> _buildGuidelinePart(Guideline guideline) {
  return [
    _PdfSegment(
      child: pw.Text('CPIC recommendation: ${guideline.cpicRecommendation}'),
    ),
    pw.SizedBox(height: 8),
    _PdfSegment(
      child: pw.Text('CPIC implication: ${guideline.cpicImplication}'),
    ),
    pw.SizedBox(height: 8),
    _PdfSegment(
      child: pw.Text('CPIC classification: ${guideline.cpicClassification}'),
    ),
    pw.SizedBox(height: 8),
    _PdfSegment(
      child: pw.Text('CPIC comment: ${guideline.cpicComment}'),
    ),
    pw.SizedBox(height: 8),
    _PdfSegment(
      child: pw.Text('CPIC implication: ${guideline.cpicImplication}'),
    ),
    pw.SizedBox(height: 8),
    _PdfSegment(
      child: pw.Text(
          'Relevant gene and phenotype: ${guideline.genePhenotype.geneSymbol.name} - ${guideline.genePhenotype.phenotype.name}'),
    ),
    pw.SizedBox(height: 8),
    _PdfSegment(
      child: pw.Text(
        'CPIC consultation text: ${guideline.genePhenotype.cpicConsultationText}',
      ),
    ),
    pw.SizedBox(height: 8),
    pw.UrlLink(child: pw.Text('Test'), destination: 'www.google.com')
  ];
}

/// Builds a row in the pdf
class _PdfSegment extends pw.StatelessWidget {
  _PdfSegment({required this.child});

  final pw.Widget child;
  @override
  pw.Widget build(Context context) {
    return pw.SizedBox(
      width: double.infinity,
      child: child,
    );
  }
}
