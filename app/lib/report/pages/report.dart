import 'package:provider/provider.dart';

import '../../common/module.dart';

@RoutePage()
class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) =>
        _buildReportPage(context, activeDrugs)
    );
  }

  Widget _buildReportPage(BuildContext context, ActiveDrugs activeDrugs) {
    final presentGenes = Set.from(UserData.instance.genotypeResults!.values.map(
      (genotypeResult) => genotypeResult.gene
    ));
    final missingGenes = Set.from(CachedDrugs.instance.allGuidelineGenes.filter(
      (gene) => !presentGenes.contains(gene)
    ));
    final userGenotypes = [
      ...UserData.instance.genotypeResults!.values,
      ...missingGenes.map(
        (gene) => GenotypeResult.missingResult(gene, context),
      ),
    ].sortedBy((genotypeResult) => genotypeResult.gene);
    final hasActiveInhibitors = activeDrugs.names.any(isInhibitor);
    return PopScope(
      canPop: false,
      child: unscrollablePageScaffold(
        title: context.l10n.tab_report,
        titleTooltip: context.l10n.report_page_faq_tooltip,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageDescription.fromText(context.l10n.report_content_explanation),
            scrollList(
              [
                PageDescription(
                  Column(
                    children: [
                      Text(context.l10n.report_legend_text),
                      SizedBox(height: PharMeTheme.smallSpace * 0.5),
                      Text.rich(WarningLevel.values.getTextLegend(context)),
                    ]
                  ),
                ),
                ...userGenotypes.map((genotypeResult) => GeneCard(
                  genotypeResult,
                  key: Key('gene-card-${genotypeResult.key.value}')
                )),
              ],
            ),
            if (hasActiveInhibitors) PageIndicatorExplanation(
              context.l10n.report_page_indicator_explanation(
                drugInteractionIndicatorName,
                drugInteractionIndicator
              ),
            ),
          ]
        )
      ),
    );
  }
}

class GeneCard extends StatelessWidget {
  const GeneCard(this.genotypeResult, { super.key });

  final GenotypeResult genotypeResult;

  @override
  Widget build(BuildContext context) {
    final phenotypeInformation = UserData.phenotypeInformationFor(
      genotypeResult,
      context,
    );
    final phenotypeText = phenotypeInformation.adaptionText.isNullOrBlank
      ? phenotypeInformation.phenotype
      : '${phenotypeInformation.phenotype}$drugInteractionIndicator';
    final affectedDrugs = CachedDrugs.instance.drugs?.filter(
      (drug) => drug.guidelineGenotypes.contains(genotypeResult.key.value)
    ) ?? [];
    return RoundedCard(
      onTap: () => context.router.push(
        GeneRoute(genotypeResult: genotypeResult)
      ),
      radius: 16,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                genotypeResult.geneDisplayString,
                style: PharMeTheme.textTheme.titleMedium
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      phenotypeText,
                      style: PharMeTheme.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text.rich(WarningLevel.values.buildLegend(
                    getText: (warningLevel) {
                      final warningLevelCount = affectedDrugs.filter(
                        (drug) => drug.warningLevel == warningLevel
                      ).length;
                      return warningLevelCount > 0
                        ? warningLevelCount.toString()
                        : null;
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded),
      ]),
    );
  }
}
