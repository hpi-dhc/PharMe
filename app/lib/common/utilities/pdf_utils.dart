import 'dart:io';

import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

import '../module.dart';

Future<String> createPdf(Drug drug) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [buildPdfPage(context, drug)],
    ),
  );
  final dir = Platform.isAndroid
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();
  await dir!.create();
  final file = File('${dir.path}/${drug.name}.pdf');
  await file.writeAsBytes(await pdf.save());
  return file.path;
}

Future<void> sharePdf(Drug drug) async {
  final path = await createPdf(drug);
  await FlutterShare.shareFile(title: drug.name, filePath: path);
}

pw.Widget buildPdfPage(
  pw.Context context,
  Drug drug,
) {
  final relevantGuidelines = drug.guidelines;
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
          drug.name,
          style: pw.TextStyle(fontSize: 26),
        ),
      ),
      pw.SizedBox(height: 8, width: double.infinity),
      _PdfSegment(
        child: pw.Text(
          drug.annotations.drugclass,
          style: pw.TextStyle(fontSize: 16),
        ),
      ),
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
          title: 'Relevant gene phenotypes: ',
          text: guideline.lookupkey.keys
              .map((geneSymbol) =>
                  '$geneSymbol: ${UserData.instance.lookups![geneSymbol]!}')
              .join(', ')),
    ),
    pw.SizedBox(height: 8, width: double.infinity),
    _PdfSegment(
      child: _PdfText(
        title: 'CPIC guideline link: ',
        text: guideline.cpicData.guidelineUrl,
      ),
    ),
    pw.SizedBox(height: 8, width: double.infinity),
    _PdfSegment(
      child: _PdfText(
        title: 'CPIC recommendation: ',
        text: guideline.cpicData.recommendation,
      ),
    ),
    pw.SizedBox(height: 8, width: double.infinity),
    ...guideline.cpicData.implications.entries
        .map((implication) => _PdfSegment(
                child: _PdfText(
              title: 'CPIC implication for ${implication.key}: ',
              text: implication.value,
            )))
        .toList(),
    pw.SizedBox(height: 8, width: double.infinity),
    _PdfSegment(
      child: _PdfText(
        title: 'CPIC comment: ',
        text: guideline.cpicData.comments,
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
