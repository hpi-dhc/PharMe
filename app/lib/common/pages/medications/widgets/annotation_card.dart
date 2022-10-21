import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n.dart';
import '../../../models/module.dart';
import '../../../theme.dart';
import '../../../widgets/module.dart';
import 'recommendation_card.dart';
import 'source_card.dart';
import 'sub_header.dart';
import 'tooltip_icon.dart';

class ClinicalAnnotationCard extends StatelessWidget {
  const ClinicalAnnotationCard(this.medication);

  final MedicationWithGuidelines medication;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SingleChildScrollView(
        child: Column(children: [
          _buildHeader(context),
          SizedBox(height: 16),
          if (medication.guidelines[0].implication.isNotNullOrBlank ||
              medication.guidelines[0].cpicImplication.isNotNullOrBlank) ...[
            _buildImplicationInfo(context),
            SizedBox(height: 16),
          ],
          if (medication.guidelines[0].recommendation.isNotNullOrBlank ||
              medication.guidelines[0].cpicRecommendation.isNotNullOrBlank) ...[
            RecommendationCard(
              medication,
              context: context,
            ),
            SizedBox(height: 16),
          ],
          _buildSourcesSection(context),
          SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _buildImplicationInfo(BuildContext context) {
    return Row(children: [
      Text(
        context.l10n.medications_page_info_big_i,
        style: GoogleFonts.robotoSlab(
          fontSize: 48,
          fontWeight: FontWeight.w900,
        ),
      ),
      SizedBox(width: 24),
      Flexible(
        child:
      Text(
        medication.guidelines[0].implication ??
            medication.guidelines[0].cpicImplication!,
        style: PharMeTheme.textTheme.bodySmall,
      ),
      )
    ]);
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.medications_page_gene_name(
            medication.guidelines[0].phenotype.geneSymbol.name,
          ),
          style: PharMeTheme.textTheme.bodyLarge!.copyWith(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        Row(children: [
          Text(
            medication.guidelines[0].cpicClassification!.toUpperCase(),
            style: PharMeTheme.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          SizedBox(width: 6),
          TooltipIcon(context.l10n.medications_page_tooltip_classification),
        ]),
      ],
    );
  }

  Widget _buildSourcesSection(BuildContext context) {
    return Column(children: [
      SubHeader(
        context.l10n.medications_page_header_further_info,
        tooltip: context.l10n.medications_page_tooltip_further_info,
      ),
      if (medication.pharmgkbId.isNotNullOrBlank) ...[
        SizedBox(height: 8),
        SourceCard(
          name: context.l10n.medications_page_sources_pharmGkb_name,
          description:
              context.l10n.medications_page_sources_pharmGkb_description,
          onTap: () => _launchPharmGkbUrl(medication.pharmgkbId),
        ),
      ],
      SizedBox(height: 8),
      SourceCard(
        name: context.l10n.medications_page_sources_cpic_name,
        description: context.l10n.medications_page_sources_cpic_description,
        onTap: () => _launchUrl(
          Uri.parse(medication.guidelines[0].cpicGuidelineUrl),
        ),
      ),
    ]);
  }
}

Future<void> _launchPharmGkbUrl(String? id) async {
  var url = 'https://pharmgkb.org';

  // redirect to specific pharmgkb page if id is present
  if (id.isNotNullOrBlank) {
    url += '/chemical/$id/clinicalAnnotation';
  }

  await _launchUrl(Uri.parse(url));
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) throw Error();
}
