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
    final hasActiveInhibitors = activeDrugs.names.any(isInhibitor);
    final notTestedString = context.l10n.general_not_tested;
    final userLookus = CachedDrugs.instance.allGuidelineGenes.map(
      (gene) => UserData.instance.lookups![gene] ??
        // Add CpicLookup for unmatched lookup
        CpicLookup(
          gene: gene,
          // phenotype will be overwritten with phenotype from lab or inhibited
          // phenotype using PhenotypeInformation in GeneCard and GenePage
          phenotype: notTestedString,
          genotype: UserData.instance.diplotypes?[gene]?.genotype ??
            notTestedString,
          lookupkey: notTestedString
        )
    ).sortedBy((lookup) => lookup.gene);
    return PopScope(
      canPop: false,
      child: unscrollablePageScaffold(
        title: context.l10n.tab_report,
        body: Column(
          children: [
            PageDescription(context.l10n.report_content_explanation),
            scrollList(
              userLookus.map((lookup) => GeneCard(
                lookup,
                key: Key('gene-card-${lookup.gene}')
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
  const GeneCard(this.lookup, { super.key });

  final CpicLookup lookup;

  @override
  Widget build(BuildContext context) {
    final phenotypeInformation = UserData.phenotypeInformationFor(
      lookup.gene,
      context,
    );
    final phenotypeText = phenotypeInformation.adaptionText.isNullOrBlank
      ? phenotypeInformation.phenotype
      : '${phenotypeInformation.phenotype}$drugInteractionIndicator';
    final affectedDrugs = CachedDrugs.instance.drugs?.filter(
      (drug) => drug.guidelineGenes.contains(lookup.gene)
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
      onTap: () => context.router.push(GeneRoute(lookup: lookup)),
      radius: 16,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lookup.gene,
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
