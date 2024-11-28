import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    ).values.sum();
  }

  List<Drug> _getAffectedDrugs(
    String genotypeResultKey,
    {
      List<String>? drugSubset,
    }) {
      final allAffectedDrugs = DrugsWithGuidelines.instance.drugs?.filter(
        (drug) => drug.guidelineGenotypes.contains(genotypeResultKey)
      ).toList() ?? [];
      if (drugSubset != null) {
        return allAffectedDrugs.filter(
          (drug) => drugSubset.contains(drug.name)
        ).toList();
      }
      return allAffectedDrugs;
    }

  List<Widget> _buildGeneCards({ List<String>? drugsToFilterBy }) {
    final userGenotypes = drugsToFilterBy != null
      ? UserData.instance.genotypeResults!.values.filter((genotypeResult) =>
          _getAffectedDrugs(
                genotypeResult.key.value,
                drugSubset: drugsToFilterBy,
          ).isNotEmpty
        )
      : UserData.instance.genotypeResults!.values;
    final warningLevelCounts = <String, WarningLevelCounts>{};
    for (final genotypeResult in userGenotypes) {
      warningLevelCounts[genotypeResult.key.value] = {};
      final affectedDrugs = _getAffectedDrugs(
        genotypeResult.key.value,
        drugSubset: drugsToFilterBy,
      );
      for (final warningLevel in WarningLevel.values) {
        warningLevelCounts[genotypeResult.key.value]![warningLevel] =
          affectedDrugs.filter(
            (drug) => drug.warningLevel == warningLevel
          ).length;
      }
    }
    var sortedGenotypes = userGenotypes.sortedBy(
      (genotypeResult) => genotypeResult.key.value
    );
    final sortedWarningLevelSeverities = Set<int>.from(
      WarningLevel.values
      .sortedBy((warningLevel) => warningLevel.severity)
      .map((warningLevel) => warningLevel.severity)
     );
    for (final severity in sortedWarningLevelSeverities) {
      sortedGenotypes = sortedGenotypes.sortedByDescending((genotypeResult) =>
        _getSeverityCount(
          warningLevelCounts[genotypeResult.key.value]!,
          severity,
        ),
      );
    }
    return sortedGenotypes.map((genotypeResult) =>
      GeneCard(
        genotypeResult,
        warningLevelCounts[genotypeResult.key.value]!,
        key: Key('gene-card-${genotypeResult.key.value}'),
        useColors: false,
      )
    ).toList();
  }

  Widget _buildReportPage(BuildContext context, ActiveDrugs activeDrugs) {
    final currentMedicationGeneCards = _buildGeneCards(drugsToFilterBy: activeDrugs.names);
    final allGeneCards = _buildGeneCards();
    final hasActiveInhibitors = activeDrugs.names.any(isInhibitor);
    return PopScope(
      canPop: false,
      child: unscrollablePageScaffold(
        title: context.l10n.tab_report,
        canNavigateBack: false,
        titleTooltip: context.l10n.report_page_faq_tooltip,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageDescription.fromText(context.l10n.report_content_explanation),
            scrollList(
              [
                PageDescription(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.report_legend_text),
                      SizedBox(height: PharMeTheme.smallSpace * 0.5),
                      Text.rich(buildWarningLevelTextLegend(context)),
                    ]
                  ),
                ),
                if (currentMedicationGeneCards.isNotEmpty) ...[
                  SubheaderDivider(
                    text: context.l10n.report_current_medications(
                      currentMedicationGeneCards.length,
                    ),
                    key: Key('header-current'),
                    useLine: false,
                  ),
                  ...currentMedicationGeneCards,
                ],
                if (
                  allGeneCards.isNotEmpty &&
                  currentMedicationGeneCards.isNotEmpty
                ) PrettyExpansionTile(
                    key: Key('header-all'),
                    title: SubheaderDivider(
                      text: context.l10n.report_all_medications(
                        allGeneCards.length,
                      ),
                      useLine: false,
                    ),
                    initiallyExpanded: true,
                    visualDensity: VisualDensity.compact,
                    titlePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    children: allGeneCards,
                  ),
                if (currentMedicationGeneCards.isEmpty) ...allGeneCards,
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

bool _hasNoResult(GenotypeResult genotypeResult) =>
  UserData.lookupFor(genotypeResult.key.value) == SpecialLookup.noResult.value;

class GeneCard extends StatelessWidget {
  const GeneCard(
    this.genotypeResult,
    this.warningLevelCounts, {
      super.key,
      this.useColors = true,
    });

  final GenotypeResult genotypeResult;
  final WarningLevelCounts warningLevelCounts;
  final bool useColors;

  @visibleForTesting
  Color? get color => !useColors || _hasNoResult(genotypeResult)
    ? PharMeTheme.onSurfaceColor
    : _getHighestSeverityColor(warningLevelCounts);

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
    final medicationIndicators =
      warningLevelCounts.values.any((count) => count > 0)
      ? DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: PharMeTheme.smallSpace * 0.35,
            horizontal: PharMeTheme.smallSpace,
          ),
          child: Text.rich(
            TextSpan(children: [
              WidgetSpan(child: Icon(
                FontAwesomeIcons.pills,
                size: PharMeTheme.textTheme.bodyMedium!.fontSize,
                color: darkenColor(PharMeTheme.iconColor, -0.1),
              )),
              TextSpan(text: ' : '),
              buildWarningLevelLegend(
                getText: (warningLevel) {
                  final warningLevelCount =
                    warningLevelCounts[warningLevel]!;
                  return warningLevelCount > 0
                    ? warningLevelCount.toString()
                    : null;
                }
              ),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          ),
        )
      : null;
    return RoundedCard(
      onTap: () => context.router.push(
        GeneRoute(genotypeResult: genotypeResult)
      ),
      radius: 16,
      color: color,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  genotypeResult.geneDisplayString,
                  style: PharMeTheme.textTheme.titleMedium
                ),
                SizedBox(height: PharMeTheme.smallSpace * 0.5),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: PharMeTheme.smallSpace * 0.5,
                  children: [
                    Text(
                      possiblyAdaptedPhenotype(context, genotypeResult, drug: null),
                      style: PharMeTheme.textTheme.titleSmall,
                    ),
                    SizedBox(width: PharMeTheme.smallSpace),
                    medicationIndicators ?? SizedBox.shrink(),
                  ],
                ),
              ]
            ),
          ),
          SizedBox(width: PharMeTheme.smallSpace),
          Column(mainAxisSize: MainAxisSize.min,children: [Icon(Icons.chevron_right_rounded)],),
        ],
      ),
    );
  }
}
