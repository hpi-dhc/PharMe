import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
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
  const ClinicalAnnotationCard(this.drug);

  final DrugWithGuidelines drug;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SingleChildScrollView(
        child: Column(children: [
          _buildHeader(context),
          SizedBox(height: 16),
          if (drug.guidelines[0].implication.isNotNullOrBlank ||
              drug.guidelines[0].cpicImplication.isNotNullOrBlank) ...[
            _buildImplicationInfo(context),
            SizedBox(height: 16),
          ],
          if (drug.guidelines[0].recommendation.isNotNullOrBlank ||
              drug.guidelines[0].cpicRecommendation.isNotNullOrBlank) ...[
            RecommendationCard(
              drug,
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
      Icon(Icons.info_outline_rounded,
          size: 48, color: PharMeTheme.onSurfaceText),
      SizedBox(width: 24),
      Flexible(
        child: Text(
          drug.guidelines[0].implication ?? drug.guidelines[0].cpicImplication!,
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
          context.l10n.drugs_page_gene_name(
            drug.guidelines[0].phenotype.geneSymbol.name,
          ),
          style: PharMeTheme.textTheme.bodyLarge!,
        ),
        Row(children: [
          Text(
            drug.guidelines[0].cpicClassification!.toUpperCase(),
            style: PharMeTheme.textTheme.bodyLarge!,
          ),
          SizedBox(width: 6),
          TooltipIcon(context.l10n.drugs_page_tooltip_classification),
        ]),
      ],
    );
  }

  Widget _buildSourcesSection(BuildContext context) {
    return Column(children: [
      SubHeader(
        context.l10n.drugs_page_header_further_info,
        tooltip: context.l10n.drugs_page_tooltip_further_info,
      ),
      if (drug.pharmgkbId.isNotNullOrBlank) ...[
        SizedBox(height: 8),
        SourceCard(
          name: context.l10n.drugs_page_sources_pharmGkb_name,
          description: context.l10n.drugs_page_sources_pharmGkb_description,
          onTap: () => _launchPharmGkbUrl(drug.pharmgkbId),
        ),
      ],
      SizedBox(height: 8),
      SourceCard(
        name: context.l10n.drugs_page_sources_cpic_name,
        description: context.l10n.drugs_page_sources_cpic_description,
        onTap: () => _launchUrl(
          Uri.parse(drug.guidelines[0].cpicGuidelineUrl),
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