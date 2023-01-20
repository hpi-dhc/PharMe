import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n.dart';
import '../../../models/module.dart';
import '../../../theme.dart';
import '../../../widgets/module.dart';
import 'recommendation_card.dart';
import 'source_card.dart';
import 'sub_header.dart';

class ClinicalAnnotationCard extends StatelessWidget {
  const ClinicalAnnotationCard(this.drug);

  final Drug drug;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SingleChildScrollView(
        child: Column(children: [
          _buildHeader(context),
          SizedBox(height: 16),
          _buildImplicationInfo(context),
          SizedBox(height: 16),
          RecommendationCard(
            drug,
            context: context,
          ),
          SizedBox(height: 16),
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
          drug.guidelines[0].annotations.implication,
          style: PharMeTheme.textTheme.bodySmall,
        ),
      )
    ]);
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      context.l10n
          .drugs_page_gene_name(drug.guidelines[0].lookupkey.keys.join(', ')),
      style: PharMeTheme.textTheme.bodyLarge!,
    );
  }

  Widget _buildSourcesSection(BuildContext context) {
    return Column(children: [
      SubHeader(
        context.l10n.drugs_page_header_further_info,
        tooltip: context.l10n.drugs_page_tooltip_further_info,
      ),
      SizedBox(height: 8),
      SourceCard(
        name: context.l10n.drugs_page_sources_cpic_name,
        description: context.l10n.drugs_page_sources_cpic_description,
        onTap: () => _launchUrl(
          Uri.parse(drug.guidelines[0].cpicData.guidelineUrl),
        ),
      ),
    ]);
  }
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) throw Error();
}
