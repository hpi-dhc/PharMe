import 'package:provider/provider.dart';

import '../../common/module.dart';

typedef WarningLevelCounts = Map<WarningLevel, int>;

@RoutePage()
class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) =>
        _buildReportPage(context, activeDrugs)
    );
  }

  int _getSeverityCount(WarningLevelCounts warningLevelCounts, int severity) {
    return warningLevelCounts.filter(
      (warningLevelCount) => warningLevelCount.key.severity == severity
    ).values.first;
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
    ];
    final warningLevelCounts = <String, WarningLevelCounts>{};
    for (final genotypeResult in userGenotypes) {
      warningLevelCounts[genotypeResult.gene] = {};
      final affectedDrugs = CachedDrugs.instance.drugs?.filter(
        (drug) => drug.guidelineGenotypes.contains(genotypeResult.key.value)
      ) ?? [];
      for (final warningLevel in WarningLevel.values) {
        warningLevelCounts[genotypeResult.gene]![warningLevel] =
          affectedDrugs.filter(
            (drug) => drug.warningLevel == warningLevel
          ).length;
      }
    }
    var sortedGenotypes = userGenotypes.sortedBy(
      (genotypeResult) => genotypeResult.gene
    );
    final sortedWarningLevels = WarningLevel.values.sortedBy(
      (warningLevel) => warningLevel.severity
    );
    for (final warningLevel in sortedWarningLevels) {
      sortedGenotypes = sortedGenotypes.sortedByDescending((genotypeResult) =>
        _getSeverityCount(
          warningLevelCounts[genotypeResult.gene]!,
          warningLevel.severity,
        ),
      );
    }
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
                ...sortedGenotypes.map((genotypeResult) => GeneCard(
                  genotypeResult,
                  warningLevelCounts[genotypeResult.gene]!,
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
  const GeneCard(this.genotypeResult, this.warningLevelCounts, { super.key });

  final GenotypeResult genotypeResult;
  final WarningLevelCounts warningLevelCounts;

  Color? _getHighestSeverityColor(WarningLevelCounts warningLevelCounts) {
    final sortedWarningLevels = WarningLevel.values.sortedByDescending(
      (warningLevel) => warningLevel.severity
    );
    return sortedWarningLevels.filter(
      (warningLevel) => warningLevelCounts[warningLevel]! > 0
    ).firstOrNull?.color;
  }

  @override
  Widget build(BuildContext context) {
    final phenotypeInformation = UserData.phenotypeInformationFor(
      genotypeResult,
      context,
    );
    final phenotypeText = phenotypeInformation.adaptionText.isNullOrBlank
      ? phenotypeInformation.phenotype
      : '${phenotypeInformation.phenotype}$drugInteractionIndicator';
    final hasLegend = warningLevelCounts.values.any((count) => count > 0);
    return RoundedCard(
      onTap: () => context.router.push(
        GeneRoute(genotypeResult: genotypeResult)
      ),
      radius: 16,
      color: _getHighestSeverityColor(warningLevelCounts),
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
                  if (hasLegend) DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 4,
                      ),
                      child: Text.rich(WarningLevel.values.buildLegend(
                        getText: (warningLevel) {
                          final warningLevelCount =
                            warningLevelCounts[warningLevel]!;
                          return warningLevelCount > 0
                            ? warningLevelCount.toString()
                            : null;
                        }),
                      ),
                    ),
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
