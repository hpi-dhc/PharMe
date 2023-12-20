import 'package:provider/provider.dart';

import '../../common/models/drug/cached_drugs.dart';
import '../../common/module.dart';
import '../../common/utilities/color_utils.dart';

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
    final hasActiveInhibitors = activeDrugs.names.any(isInhibitor);
    final notTestedString = context.l10n.general_not_tested;
    final userPhenotypes = CachedDrugs.instance.allGuidelineGenes.map(
      (geneSymbol) => UserData.instance.lookups![geneSymbol] ??
      CpicPhenotype(
        geneSymbol: geneSymbol,
        phenotype: notTestedString,
        genotype: notTestedString,
        lookupkey: notTestedString
      )
    );
    return PopScope(
      canPop: false,
      child: unscrollablePageScaffold(
        title: context.l10n.tab_report,
        barBottom: context.l10n.report_content_explanation,
        body: Column(
          children: [
            if (hasActiveInhibitors) PageIndicatorExplanation(
              context.l10n.report_page_indicator_explanation(
                drugInteractionIndicatorName,
                drugInteractionIndicator
              ),
            ),
            scrollList(
              userPhenotypes.map((phenotype) => GeneCard(
                phenotype,
                key: Key('gene-card-${phenotype.geneSymbol}')
              )).toList(),
            ),
          ]
        )
      ),
    );
  }
}

class GeneCard extends StatelessWidget {
  const GeneCard(this.phenotype, { super.key });

  final CpicPhenotype phenotype;

  @override
  Widget build(BuildContext context) {
    final phenotypeInformation = UserData.phenotypeFor(
      phenotype.geneSymbol,
      context,
    );
    final phenotypeText = phenotypeInformation.adaptionText.isNullOrBlank
      ? phenotypeInformation.phenotype
      : '${phenotypeInformation.phenotype}$drugInteractionIndicator';
    final affectedDrugs = CachedDrugs.instance.drugs?.filter(
      (drug) => drug.guidelineGenes.contains(phenotype.geneSymbol)
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
            SizedBox(width: PharMeTheme.smallSpace / 2),
            Text(
              warningLevelCount.toString(),
              style: TextStyle(color: textColor),
            ),
            SizedBox(width: PharMeTheme.smallSpace),
          ]
        )
        : SizedBox.shrink();
      }
    ).toList();
    return RoundedCard(
      onTap: () => context.router.push(GeneRoute(phenotype: phenotype)),
      innerPadding: EdgeInsets.all(PharMeTheme.smallSpace),
      radius: 16,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phenotype.geneSymbol,
                style: PharMeTheme.textTheme.titleMedium
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    phenotypeText,
                    style: PharMeTheme.textTheme.titleSmall
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
