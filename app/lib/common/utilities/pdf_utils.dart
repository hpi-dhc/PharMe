import 'dart:io';

import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import '../module.dart';

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
      ..._buildHeader(drug, buildContext),
      _buildTextBlockSpacer(),
      _buildTextSpacer(),
      ..._buildDrugPart(drug, buildContext),
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

List<pw.Widget> _buildHeader(Drug drug, BuildContext buildContext) {
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
        buildContext.l10n.pdf_pgx_report,
        style: pw.TextStyle(
          fontSize: PharMeTheme.mediumSpace,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  ];
}

List<pw.Widget> _buildDrugPart(Drug drug, BuildContext buildContext) {
  return [
    _PdfSegment(
      child: _PdfDescription(
        title: buildContext.l10n.drugs_page_header_drugclass,
        text:  drug.annotations.drugclass,
      ),
    ),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: buildContext.l10n.pdf_indication,
        text:  drug.annotations.indication,
      ),
    ),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: buildContext.l10n.pdf_brand_names,
        text: drug.annotations.brandNames.join(', '),
      ),
    ),
  ];
}

String? _getPhenotypeInfo(String gene, Drug drug, BuildContext context) {
  final phenotypeInformation = UserData.phenotypeFor(
    gene,
    context,
    drug: drug.name,
    userSalutation: context.l10n.general_the_user,  
  );
  if (phenotypeInformation.adaptionText.isNullOrBlank) {
    return phenotypeInformation.phenotype;
  }
  var phenotypeInformationText = '${phenotypeInformation.phenotype} ('
    '${phenotypeInformation.adaptionText}';
  if (phenotypeInformation.overwrittenPhenotype.isNotNullOrBlank) {
    phenotypeInformationText = '$phenotypeInformationText; '
      '${context.l10n.drugs_page_original_phenotype(
        phenotypeInformation.overwrittenPhenotype!
      )}';
  }
  return '$phenotypeInformationText)';
}

String? _getActivityScoreInfo(String gene, Drug drug, BuildContext context) {
  final originalLookup = UserData.lookupFor(
    gene,
    drug: drug.name,
    useOverwrite: false,
  );
  final overwrittenLookup = UserData.lookupFor(
    gene,
    drug: drug.name,
    useOverwrite: true,
  );
  if (originalLookup == overwrittenLookup) return originalLookup;
  return '$overwrittenLookup '
    '(${context.l10n.pdf_activity_score_overwrite(
      originalLookup ?? context.l10n.pdf_no_value
    )})';
}

String _userInfoPerGene(
  Drug drug,
  String? Function(String, Drug, BuildContext) getInfo,
  BuildContext buildContext,  
) {
  if (drug.guidelines.isEmpty) return buildContext.l10n.pdf_no_value;
  final guidelineGenes = drug.guidelines.first.lookupkey.keys.toList();
  return guidelineGenes.map((gene) =>
    '$gene: ${
      getInfo(gene, drug, buildContext) ?? buildContext.l10n.pdf_no_value
    }'
  ).join(', ');
}

List<pw.Widget> _buildUserPart(
  pw.Context context,
  BuildContext buildContext,
  Drug drug,
  Font emoji,
) {
  final userGuideline = drug.userGuideline();
  final patientGenotype = _userInfoPerGene(
    drug,
    (gene, drug, context) => UserData.genotypeFor(gene),
    buildContext,
  );
  final patientPhenotype = _userInfoPerGene(
    drug,
    _getPhenotypeInfo,
    buildContext,
  );
  final patientActivityScore = _userInfoPerGene(
    drug,
    _getActivityScoreInfo,
    buildContext
  );
  final allelesTested = _userInfoPerGene(
    drug,
    (gene, drug, context) => UserData.allelesTestedFor(gene),
    buildContext,
  );
  final warningLevelIcons = {
    'red': '❌',
    'yellow': '⚠',
    'green': '✅',
    null: '❔',
  };
  final implication = userGuideline?.annotations.implication ??
    buildContext.l10n.drugs_page_no_guidelines_for_phenotype_implication(
      drug.name
    );
  final recommendation = userGuideline?.annotations.recommendation ??
    buildContext.l10n.drugs_page_no_guidelines_for_phenotype_recommendation;
  return [
    _buildSubheading(buildContext.l10n.pdf_heading_user_data),
    _buildTextBlockSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: buildContext.l10n.gene_page_genotype,
        text: patientGenotype,
      ),
    ),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: buildContext.l10n.gene_page_phenotype,
        text: patientPhenotype
      ),
    ),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: buildContext.l10n.gene_page_activity_score,
        text: patientActivityScore
      ),
    ),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: buildContext.l10n.pdf_tested_alleles,
        text:  allelesTested,
      ),
    ),
    _buildTextBlockSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: buildContext.l10n.pdf_user_guideline,
        text: '$implication $recommendation',
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
    [ heading, _buildTextBlockSpacer(), pw.Text(buildContext.l10n.pdf_no_value) ] :
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
          ..._buildGuidelinePart(guideline, buildContext)
        ]
      ),
      _buildTextDivider()
    ];
}

List<pw.Widget> _buildGuidelinePart(
  GuidelineExtData guideline,
  BuildContext buildContext
) {
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
        title: buildContext.l10n.pdf_guideline_link(guideline.source)
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
          title: buildContext.l10n.pdf_guideline_recommmendation(
            guideline.source,
          ),
          text: guideline.recommendation),
    ),
    _buildTextSpacer(),
    ...guideline.implications.entries
        .map((implication) => _PdfSegment(
                child: _PdfDescription(
              title:
                  buildContext.l10n.pdf_guideline_gene_implication(
                    guideline.source,
                    implication.key
                  ),
              text: implication.value,
            )))
        .toList(),
    _buildTextSpacer(),
    _PdfSegment(
      child: _PdfDescription(
        title: buildContext.l10n.pdf_guideline_comment(guideline.source),
        text: guideline.comments.isNullOrBlank ?
          buildContext.l10n.pdf_no_value :
          guideline.comments
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
