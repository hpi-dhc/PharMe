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
        body: Column(
          children: [
            PageDescription(context.l10n.report_content_explanation),
            scrollList(
              userGenotypes.map((genotypeResult) => GeneCard(
                genotypeResult,
                key: Key('gene-card-${genotypeResult.key}')
              )).toList(),
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
      (drug) => drug.guidelineGenotypes.contains(genotypeResult.key)
    ) ?? [];
    final warningLevelIndicators = WarningLevel.values.map(
      (warningLevel) {
        final warningLevelCount = affectedDrugs.filter(
          (drug) => drug.warningLevel == warningLevel
        ).length;
        final textColor = darkenColor(warningLevel.color, 0.4);
        return warningLevelCount > 0
        ? Row(
            textDirection: TextDirection.ltr,
            children: [
              Icon(
                warningLevel.icon,
                size: PharMeTheme.mediumSpace,
                color: textColor,
              ),
              SizedBox(width: PharMeTheme.smallSpace * 0.4),
              Text(
                warningLevelCount.toString(),
                style: TextStyle(color: textColor),
              ),
              SizedBox(width: PharMeTheme.smallSpace * 0.8),
            ]
          )
        : SizedBox.shrink();
      }
    ).toList();
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
                genotypeResult.gene,
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
                  Row(children: warningLevelIndicators),
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
