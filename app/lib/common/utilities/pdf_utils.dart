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
  final relevantGuidelines = medication.filterUserGuidelines().guidelines;
  return pw.Wrap(
    children: [
      _PdfSegment(
        child: pw.Text(
          'Personal PGX Report',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 30,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 20, width: double.infinity),
      _PdfSegment(
        child: pw.Text(
          medication.name,
          style: pw.TextStyle(fontSize: 26),
        ),
      ),
      if (medication.drugclass.isNotNullOrBlank) ...[
        pw.SizedBox(height: 8, width: double.infinity),
        _PdfSegment(
          child: pw.Text(
            medication.drugclass!,
            style: pw.TextStyle(fontSize: 16),
          ),
        ),
      ],
      if (medication.description.isNotNullOrBlank) ...[
        pw.SizedBox(height: 8, width: double.infinity),
        _PdfSegment(
          child: pw.Text(
            medication.description!,
            style: pw.TextStyle(fontSize: 12),
          ),
        )
      ],
      pw.SizedBox(height: 32, width: double.infinity),
      for (final guideline in relevantGuidelines)
        ..._buildGuidelinePart(guideline),
    ],
  );
}

List<pw.Widget> _buildGuidelinePart(Guideline guideline) {
  return [
    _PdfSegment(
      child: _PdfText(
        title: 'CPIC Recommendation: ',
        text: guideline.cpicRecommendation,
      ),
    ),
    pw.SizedBox(height: 8, width: double.infinity),
    _PdfSegment(
      child: _PdfText(
        title: 'CPIC Implication: ',
        text: guideline.cpicImplication,
      ),
    ),
    pw.SizedBox(height: 8, width: double.infinity),
    _PdfSegment(
      child: _PdfText(
        title: 'CPIC Classification: ',
        text: guideline.cpicClassification,
      ),
    ),
    pw.SizedBox(height: 8, width: double.infinity),
    _PdfSegment(
      child: _PdfText(
        title: 'CPIC Comment: ',
        text: guideline.cpicComment,
      ),
    ),
    pw.SizedBox(height: 8, width: double.infinity),
    _PdfSegment(
      child: _PdfText(
        title: 'Relevant Gene and Phenotype: ',
        text:
            '${guideline.phenotype.geneSymbol.name} - ${guideline.phenotype.geneResult.name}',
      ),
    ),
    pw.SizedBox(height: 8, width: double.infinity),
    _PdfSegment(
      child: _PdfText(
        title: 'CPIC Consultation Text: ',
        text: guideline.phenotype.cpicConsulationText,
      ),
    ),
    pw.SizedBox(height: 8, width: double.infinity),
    _PdfSegment(
      child: _PdfText(
        title: 'CPIC Guideline Link: ',
        text: guideline.cpicGuidelineUrl,
      ),
    ),
    pw.SizedBox(height: 8, width: double.infinity),
    pw.Divider(color: PdfColors.grey500),
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

class _PdfText extends pw.StatelessWidget {
  _PdfText({required this.title, this.text});

  final String title;
  final String? text;
  @override
  pw.Widget build(Context context) {
    return pw.RichText(
      text: pw.TextSpan(
          text: title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          children: [
            if (text.isNotNullOrBlank)
              pw.TextSpan(
                text: text,
                style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
              )
          ]),
    );
  }
}
