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
                  _buildResultSection(context),
                  SizedBox(height: PharMeTheme.smallToMediumSpace),
                  _buildSourcesSection(context),
                  SizedBox(height: PharMeTheme.mediumSpace),
                  GuidelineDisclaimer(userGuideline: drug.userGuideline),
                ]
                else ...[
                  _buildResultSection(context),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(BuildContext context) {
    final implicationText = drug.userGuideline?.annotations.implication;
    final recommendationText = drug.userGuideline?.annotations.recommendation;
    final descriptionStyle = TextStyle(fontStyle: FontStyle.italic);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPhenotype(context),
        SizedBox(height: PharMeTheme.smallToMediumSpace),
        RoundedCard(
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
                  children: [
                    if (
                      implicationText != null &&
                      drug.warningLevel != WarningLevel.none
                    ) TextSpan(
                      text: context.l10n.drugs_page_implication_description,
                      style: descriptionStyle,
                    ),
                    TextSpan(text: ':\n', style: descriptionStyle),
                    WidgetSpan(child: SizedBox(height: PharMeTheme.mediumSpace * 1.3)),
                    TextSpan(
                      text:
                        implicationText ?? context.l10n.drugs_page_no_guidelines_text,
                      style: implicationText != null
                        ? TextStyle(fontWeight: FontWeight.bold)
                        : TextStyle(fontStyle: FontStyle.italic)
                        ),
                  ],
                ),
              ),
              if (recommendationText != null) ...[
                SizedBox(height: PharMeTheme.mediumSpace),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: context.l10n.drugs_page_recommendation_description_part_1,
                      style: descriptionStyle,
                    ),
                    TextSpan(
                      text: context.l10n.drugs_page_recommendation_description_part_2,
                      style: descriptionStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ':\n', style: descriptionStyle),
                    WidgetSpan(child: SizedBox(height: PharMeTheme.mediumSpace * 1.3)),
                    TextSpan(
                      text: recommendationText,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ]),
                ),
              ],
            ]
          )
        ),
        _maybeBuildPhenoconversionInformation(context) ?? SizedBox.shrink(),
      ],
    );
  }

  String _buildGuidelineTooltipText(BuildContext context) {
    return drug.userGuideline != null
      ? context.l10n.drugs_page_tooltip_guideline_present(
          drug.userOrFirstGuideline!.externalData.first.source
        )
      : context.l10n.drugs_page_tooltip_guideline_missing;
  }

  Widget _buildPhenotype(BuildContext context) {
    final genotypeResults = getGenotypeResultsForDrug(drug);
    if (genotypeResults == null) {
      return Text(
        context.l10n.drugs_page_guidelines_empty(drug.name),
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }
    return buildTable(
      genotypeResults.map((genotypeResult) =>
        phenotypeTableRow(
          context,
          key: genotypeResult.geneDisplayString,
          genotypeResult: genotypeResult,
          drug: drug.name,
        ),
      ).toList(),
    );
  }

  Widget? _maybeBuildPhenoconversionInformation(BuildContext context) {
    final phenoconversionExplanation = getUserPhenoconversionExplanation(drug);
    if (phenoconversionExplanation == null) return null;
    return Padding(
      padding: EdgeInsets.only(top: PharMeTheme.smallSpace),
      child: phenoconversionExplanation,
    );
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
