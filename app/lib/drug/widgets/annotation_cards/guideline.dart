import 'package:url_launcher/url_launcher.dart';

import '../../../common/module.dart';
import '../module.dart';

enum WarfarinContent {
  tooltip,
  implication,
  recommendation,
  color,
  icon,
  heading,
}

final warfarinProperties = <WarfarinContent, dynamic Function(BuildContext)>{
  WarfarinContent.tooltip: (context) =>
    context.l10n.drugs_page_tooltip_warfarin,
  WarfarinContent.implication: (context) =>
    context.l10n.drugs_page_implication_warfarin,
  WarfarinContent.recommendation: (context) =>
    context.l10n.drugs_page_recommendation_warfarin,
  WarfarinContent.color: (_) => WarningLevel.none.color,
  WarfarinContent.icon: (_) => WarningLevel.none.icon,
  WarfarinContent.heading: (context) => WarningLevel.none.getLabel(context),
};

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
                _buildHeader(context),
                SizedBox(height: PharMeTheme.mediumSpace),
                _buildCard(context),
                SizedBox(height: PharMeTheme.mediumSpace),
                _buildSourcesSection(context),
              ]
              else ...[
                _buildHeader(context),
                SizedBox(height: PharMeTheme.smallSpace),
                _buildCard(context),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  dynamic actualOrWarfarinContent(String drugName, BuildContext context, {
    required dynamic actualContent,
    required WarfarinContent warfarinContent,
  }) {
    if (drugName.toLowerCase() == 'warfarin') {
      final getWarfarinContent = warfarinProperties[warfarinContent]!;
      return getWarfarinContent(context);
    }
    return actualContent;
  }

  Widget _buildCard(BuildContext context) {
    final implicationText = actualOrWarfarinContent(
      drug.name,
      context,
      actualContent: drug.userGuideline?.annotations.implication ??
        context.l10n.drugs_page_no_guidelines_for_phenotype_implication(
          drug.name
        ),
      warfarinContent: WarfarinContent.implication,
    );
    final recommendationText = actualOrWarfarinContent(
      drug.name,
      context,
      actualContent: drug.userGuideline?.annotations.recommendation ??
        context.l10n.drugs_page_no_guidelines_for_phenotype_recommendation,
      warfarinContent: WarfarinContent.recommendation,
    );
    return RoundedCard(
      key: Key('annotationCard'),
      radius: PharMeTheme.innerCardRadius,
      outerHorizontalPadding: 0,
      outerVerticalPadding: 0,
      color: actualOrWarfarinContent(
        drug.name,
        context,
        actualContent: drug.warningLevel.color,
        warfarinContent: WarfarinContent.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  actualOrWarfarinContent(
                    drug.name,
                    context,
                    actualContent: drug.warningLevel.icon,
                    warfarinContent: WarfarinContent.icon,
                  ),
                  color: PharMeTheme.onSurfaceText,
                  size: PharMeTheme.mediumToLargeSpace,
                ),
              ),
              TextSpan(
                text: ' ${actualOrWarfarinContent(
                  drug.name,
                  context,
                  actualContent: drug.warningLevel.getLabel(context),
                  warfarinContent: WarfarinContent.heading,
                )}',
              ),
            ]),
            style: PharMeTheme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: PharMeTheme.smallToMediumSpace),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: context.l10n.drugs_page_implication_description,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: implicationText),
            ]),
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
    final actualTooltip = drug.userGuideline != null
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
    return actualOrWarfarinContent(
      drug.name,
      context,
      actualContent: actualTooltip,
      warfarinContent: WarfarinContent.tooltip,
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (drug.userGuideline == null && drug.guidelines.isEmpty) {
      return Text(
        context.l10n.drugs_page_guidelines_empty(drug.name),
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    } else {
      final geneDescriptions = drug.guidelineGenotypes.map((genotypeKey) {
        final phenotypeInformation = UserData.phenotypeInformationFor(
          UserData.instance.genotypeResults!.findOrMissing(
            genotypeKey,
            context,
          ),
          context,
          drug: drug.name,
        );
        var description = phenotypeInformation.phenotype;
        if (phenotypeInformation.adaptionText.isNotNullOrBlank) {
          description = '$description (${phenotypeInformation.adaptionText})';
        }
        return TableRowDefinition(genotypeKey, description);
      });
      return buildTable(geneDescriptions.toList());
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
