import 'dart:io';

import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import '../module.dart';

const noValueString = 'n/a';

Future<String> createPdf(
  Drug drug,
  BuildContext buildContext,
  Font emoji,
) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [buildPdfPage(context, buildContext, drug, emoji)],
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

Future<void> sharePdf(Drug drug, BuildContext context) async {
  final emoji = await PdfGoogleFonts.notoColorEmoji();
  // ignore: use_build_context_synchronously
  final path = await createPdf(drug, context, emoji);
  await FlutterShare.shareFile(title: drug.name.capitalize(), filePath: path);
}

pw.Widget buildPdfPage(
  pw.Context context,
  BuildContext buildContext,
  Drug drug,
  Font emoji,
) {
  return pw.Wrap(
    children: [
      ..._buildHeader(drug),
      _buildTextBlockSpacer(),
      _buildTextSpacer(),
      ..._buildDrugPart(drug),
      _buildTextBlockSpacer(),
      ..._buildUserPart(context, buildContext, drug, emoji),
      _buildTextBlockSpacer(),
      ..._buildExternalGuidelinePart(drug, buildContext),
    ],
  );
}

pw.SizedBox _buildTextBlockSpacer() =>
  pw.SizedBox(height: PharMeTheme.mediumSpace, width: double.infinity);

pw.SizedBox _buildTextSpacer() =>
  pw.SizedBox(height: PharMeTheme.smallSpace, width: double.infinity);

pw.Divider _buildTextDivider() => 
  pw.Divider(color: PdfColors.grey500);

pw.Text _buildSubheading(String text) => pw.Text(
  text,
  style: pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    fontSize: PharMeTheme.mediumSpace,
  ),
);

List<pw.Widget> _buildHeader(Drug drug) {
  return [
    _PdfSegment(
      child: pw.Text(
        drug.name.capitalize(),
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: PharMeTheme.largeSpace,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
    _buildTextSpacer(),
    _PdfSegment(
      child: pw.Text(
        'PGx report',
        style: pw.TextStyle(
          fontSize: PharMeTheme.mediumSpace,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  ];
}

List<pw.Widget> _buildDrugPart(Drug drug) {
  return [
    _PdfSegment(
      child: _PdfDescription(
        title: 'Drug class',
        text:  drug.annotations.drugclass,
      ),
    ),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: 'Indication',
        text:  drug.annotations.indication,
      ),
    ),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: 'Brand names',
        text: drug.annotations.brandNames.join(', '),
      ),
    ),
  ];
}

String _getPhenotypeInfo(String gene) {
  final phenotype = UserData.phenotypeFor(gene) ?? noValueString;
  final lookup = UserData.lookupFor(gene) ?? noValueString;
  return lookup == phenotype ? phenotype : '$phenotype ($lookup)';
}

String _userInfoPerGene(Drug drug, String? Function(String gene) getInfo) {
  if (drug.guidelines.isEmpty) return noValueString;
  final guidelineGenes = drug.guidelines.first.lookupkey.keys.toList();
  return guidelineGenes.map((gene) =>
    '$gene: ${getInfo(gene) ?? noValueString}'
  ).join(', ');
}

List<pw.Widget> _buildUserPart(
  pw.Context context,
  BuildContext buildContext,
  Drug drug,
  Font emoji,
) {
  final userGuideline = drug.userGuideline();
  final patientGenotype = _userInfoPerGene(drug, UserData.genotypeFor);
  final patientPhenotype = _userInfoPerGene(drug, _getPhenotypeInfo);
  final allelesTested = _userInfoPerGene(drug, UserData.allelesTestedFor);
  final warningLevelIcons = {
    'red': '❌',
    'yellow': '⚠',
    'green': '✅',
    null: '❔',
  };
  return [
    _buildSubheading(buildContext.l10n.pdf_heading_user_data),
    _buildTextBlockSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: 'Genotype',
        text: patientGenotype,
      ),
    ),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: 'Phenotype',
        text: patientPhenotype
      ),
    ),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: 'Tested alleles',
        text:  allelesTested,
      ),
    ),
    _buildTextBlockSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: 'User guideline',
        text:  userGuideline != null ?
          '${userGuideline.annotations.implication} '
            ' ${userGuideline.annotations.recommendation}' :
          buildContext.l10n.drugs_page_no_guidelines_for_phenotype(drug.name),
        icon: warningLevelIcons[userGuideline?.annotations.warningLevel.name],
        emojiFont: emoji,
      ),
    ),
  ];
}

List<pw.Widget> _buildExternalGuidelinePart(
  Drug drug,
  BuildContext buildContext
) {
  final externalData = drug.userGuideline()?.externalData;
  final heading = _buildSubheading(
    buildContext.l10n.pdf_heading_clinical_guidelines
  );
  return externalData == null ?
    [ heading, _buildTextBlockSpacer(), pw.Text(noValueString) ] :
    [
      heading,
      _buildTextBlockSpacer(),
      pw.Text(
        buildContext.l10n.pdf_info_clinical_guidelines,
        style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
      ),
      ...externalData.fold([], (externalGuidelines, guideline) =>
        [
          ...externalGuidelines,
          _buildTextBlockSpacer(),
          _buildTextDivider(),
          ..._buildGuidelinePart(guideline)
        ]
      ),
      _buildTextDivider()
    ];
}

List<pw.Widget> _buildGuidelinePart(GuidelineExtData guideline) {
  return [
    _PdfSegment(
      child: pw.Text(
        guideline.guidelineName,
        style: pw.TextStyle(fontWeight: FontWeight.bold),
      )
    ),
    _buildTextBlockSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: '${guideline.source} guideline link'
      ),
    ),
    _PdfSegment(child:
      pw.UrlLink(
        child: pw.Text(
          guideline.guidelineUrl,
          style: pw.TextStyle(
            color: PdfColors.blue500,
            decoration: pw.TextDecoration.underline,
          )
        ),
        destination: guideline.guidelineUrl,
      )
    ),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
          title: '${guideline.source} recommendation',
          text: guideline.recommendation),
    ),
    _buildTextSpacer(),
    ...guideline.implications.entries
        .map((implication) => _PdfSegment(
                child: _PdfDescription(
              title:
                  '${guideline.source} implication for ${implication.key}',
              text: implication.value,
            )))
        .toList(),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: '${guideline.source} comment',
        text: guideline.comments,
      ),
    ),
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

class _PdfDescription extends pw.StatelessWidget {
  _PdfDescription({required this.title, this.text, this.icon, this.emojiFont});
  final String title;
  final String? text;
  final String? icon;
  final Font? emojiFont;
  @override
  pw.Widget build(Context context) {
    return pw.RichText(
      text: pw.TextSpan(
          text: '$title: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          children: [
            if (icon.isNotNullOrBlank)
              pw.TextSpan(
                text: '$icon ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.normal,
                  fontFallback: [emojiFont!],
                )
              ),
            if (text.isNotNullOrBlank)
              pw.TextSpan(
                text: text,
                style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
              ),
          ]),
    );
  }
}
