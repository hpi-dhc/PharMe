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

  Widget _buildReportPage(BuildContext context, ActiveDrugs activeDrugs) {
    final userGenotypes = UserData.instance.genotypeResults!.values;
    final warningLevelCounts = <String, WarningLevelCounts>{};
    for (final genotypeResult in userGenotypes) {
      warningLevelCounts[genotypeResult.key.value] = {};
      final affectedDrugs = DrugsWithGuidelines.instance.drugs?.filter(
        (drug) => drug.guidelineGenotypes.contains(genotypeResult.key.value)
      ) ?? [];
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
    final sortedGenotypesWithResults = sortedGenotypes.filter(
      (genotypeResult) => !_hasNoResult(genotypeResult)
    );
    final sortedGenotypesWithoutResults = sortedGenotypes.filter(_hasNoResult);
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
                ...sortedGenotypesWithResults.map((genotypeResult) => GeneCard(
                  genotypeResult,
                  warningLevelCounts[genotypeResult.key.value]!,
                  key: Key('gene-card-${genotypeResult.key.value}')
                )),
                if (sortedGenotypesWithoutResults.isNotEmpty) ...[
                  SubheaderDivider(
                    text: context.l10n.report_no_result_genes,
                    key: Key('header-no-result'),
                    useLine: false,
                  ),
                  ...sortedGenotypesWithoutResults.map((genotypeResult) =>
                    GeneCard(
                      genotypeResult,
                      warningLevelCounts[genotypeResult.key.value]!,
                      key: Key('gene-card-${genotypeResult.key.value}')
                    )
                  ),
                ],
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
  const GeneCard(this.genotypeResult, this.warningLevelCounts, { super.key });

  final GenotypeResult genotypeResult;
  final WarningLevelCounts warningLevelCounts;

  @visibleForTesting
  Color? get color => _hasNoResult(genotypeResult)
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
    final hasLegend = warningLevelCounts.values.any((count) => count > 0);
    return RoundedCard(
      onTap: () => context.router.push(
        GeneRoute(genotypeResult: genotypeResult)
      ),
      radius: 16,
      color: color,
      child: IntrinsicHeight(child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                genotypeResult.geneDisplayString,
                style: PharMeTheme.textTheme.titleMedium
              ),
              SizedBox(height: 8),
              Text(
                possiblyAdaptedPhenotype(context, genotypeResult, drug: null),
                style: PharMeTheme.textTheme.titleSmall,
              ),
            ],
          ),
          Expanded(
            child: hasLegend
              ? Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                padding: EdgeInsets.only(
                  left: PharMeTheme.mediumSpace,
                  right: PharMeTheme.smallSpace,
                ),
                child: DecoratedBox(
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
                    buildWarningLevelLegend(
                      getText: (warningLevel) {
                        final warningLevelCount =
                          warningLevelCounts[warningLevel]!;
                        return warningLevelCount > 0
                          ? warningLevelCount.toString()
                          : null;
                      }
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ),
                )),
              )
              : SizedBox.shrink(),
          ),
          Icon(Icons.chevron_right_rounded),
        ]
      )),
    );
  }
}
