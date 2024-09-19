import 'package:url_launcher/url_launcher.dart';

import '../../../common/module.dart';
import '../module.dart';

class GuidelineAnnotationCard extends StatelessWidget {
  const GuidelineAnnotationCard(this.drug);

  final Drug drug;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubHeader(
          context.l10n.drugs_page_header_guideline,
          tooltip: _buildGuidelineTooltipText(context),
        ),
        SizedBox(height: PharMeTheme.smallSpace),
        RoundedCard(
          innerPadding: const EdgeInsets.all(PharMeTheme.mediumSpace),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (drug.guidelines.isNotEmpty) ...[
                ..._buildHeader(context),
                SizedBox(height: PharMeTheme.mediumSpace),
                _buildCard(context),
                SizedBox(height: PharMeTheme.mediumSpace),
                _buildSourcesSection(context),
              ]
              else ...[
                ..._buildHeader(context),
                SizedBox(height: PharMeTheme.smallSpace),
                _buildCard(context),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    final implicationText = drug.userGuideline?.annotations.implication ??
        context.l10n.drugs_page_no_guidelines_for_phenotype_implication(
          drug.name
        );
    final recommendationText = drug.userGuideline?.annotations.recommendation ??
        context.l10n.drugs_page_no_guidelines_for_phenotype_recommendation;
    return RoundedCard(
      key: Key('annotationCard'),
      radius: PharMeTheme.innerCardRadius,
      outerHorizontalPadding: 0,
      outerVerticalPadding: 0,
      color: drug.warningLevel.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  drug.warningLevel.icon,
                  color: PharMeTheme.onSurfaceText,
                  size: PharMeTheme.mediumToLargeSpace,
                ),
              ),
              TextSpan(
                text: ' ${drug.warningLevel.getLabel(context)}',
              ),
            ]),
            style: PharMeTheme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: PharMeTheme.smallToMediumSpace),
          Text.rich(
            TextSpan(text: implicationText),
          ),
          SizedBox(height: PharMeTheme.smallToMediumSpace),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: context.l10n.drugs_page_recommendation_description,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: recommendationText),
            ]),
          ),
          ...[
            SizedBox(height: PharMeTheme.smallToMediumSpace),
            Disclaimer(userGuideline: drug.userGuideline),
          ],
        ]
      )
    );
  }

  String _buildGuidelineTooltipText(BuildContext context) {
    return drug.userGuideline != null
      // Case 1: a guideline is present
      ? context.l10n.drugs_page_tooltip_guideline(
          drug.userGuideline!.externalData.first.source
        )
      : drug.userOrFirstGuideline != null
        // Case 2: a guideline for the drug is present but not for the genotype
        ? drug.guidelineGenotypes.all(UserData.instance.genotypeResults!.isMissing)
          // Case 2.1: all genes are not tested
          ? context.l10n.drugs_page_tooltip_missing_guideline_not_tested
          // Case 2.2: at least some genes tested
          : context.l10n.drugs_page_tooltip_missing_guideline_for_drug_or_genotype(
            context.l10n.drugs_page_tooltip_missing_genotype
          )
        // Case 3: the drug has no guidelines
        : context.l10n.drugs_page_tooltip_missing_guideline_for_drug_or_genotype(
            context.l10n.drugs_page_tooltip_missing_drug
          );
  }

  List<Widget> _buildHeader(BuildContext context) {
    if (drug.userGuideline == null && drug.guidelines.isEmpty) {
      return [
        Text(
          context.l10n.drugs_page_guidelines_empty(drug.name),
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ];
    } else {
      final genotypeResults = drug.guidelineGenotypes.map((genotypeKey) =>
        UserData.instance.genotypeResults!.findOrMissing(
          genotypeKey,
          context,
        )
      ).toList();
      final geneDescriptions = genotypeResults.map((genotypeResult) =>
        TableRowDefinition(
          genotypeResult.geneDisplayString,
          possiblyAdaptedPhenotype(
            genotypeResult,
            drug: drug.name,
          ),
        )
      ).toList();
      return [
        buildTable(geneDescriptions),
        if (genotypeResults.any(
          (genotypeResult) => isInhibited(genotypeResult, drug: drug.name)
        )) ...[
          SizedBox(height: PharMeTheme.smallSpace),
          buildDrugInteractionInfo(
            context,
            genotypeResults,
            drug: drug.name,
          ),
        ],
      ];
    }
  }

  Widget _buildSourcesSection(BuildContext context) {
    // pipes are illegal characters in URLs so please
    // - forgive the cheap hack or
    // - refactor by making a custom object and defining equality for it :)
    final guideline = drug.userOrFirstGuideline!;
    final sources = guideline.externalData
        .map((data) => '${data.source}|${data.guidelineUrl}')
        .toSet();
    return Column(children: [
      ...sources.map(
        (source) => GestureDetector(
          onTap: () => _launchUrl(Uri.parse(source.split('|')[1])),
          child: RoundedCard(
            radius: PharMeTheme.innerCardRadius,
            outerHorizontalPadding: 0,
            outerVerticalPadding: 0,
            color: darkenColor(PharMeTheme.onSurfaceColor, 0.05),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                child: Text(context.l10n
                    .drugs_page_sources_description(source.split('|')[0])),
              ),
              Icon(Icons.chevron_right_rounded)
            ])
          ),
        ),
      ),
    ]);
  }
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) throw Error();
}
