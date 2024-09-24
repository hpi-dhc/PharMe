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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    final implicationText = drug.userGuideline?.annotations.implication;
    final recommendationText = drug.userGuideline?.annotations.recommendation;
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
            TextSpan(
              text:
                implicationText ?? context.l10n.drugs_page_no_guidelines_text,
            ),
          ),
          if (recommendationText != null) ...[
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
          ],
          SizedBox(height: PharMeTheme.smallToMediumSpace),
          Disclaimer(userGuideline: drug.userGuideline),
        ]
      )
    );
  }

  String _buildGuidelineTooltipText(BuildContext context) {
    return drug.userGuideline != null
      ? context.l10n.drugs_page_tooltip_guideline_present(
          drug.userOrFirstGuideline!.externalData.first.source
        )
      : context.l10n.drugs_page_tooltip_guideline_missing;
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
        UserData.instance.genotypeResults![genotypeKey] ??
          // Should not be null but to be safe
          GenotypeResult.missingResult(
            GenotypeKey.extractGene(genotypeKey),
            variant: GenotypeKey.maybeExtractVariant(genotypeKey),
          )
      ).toList();
      final geneDescriptions = genotypeResults.map((genotypeResult) =>
        TableRowDefinition(
          genotypeResult.geneDisplayString,
          possiblyAdaptedPhenotype(
            context,
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
            key: Key('sourceCard'),
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
