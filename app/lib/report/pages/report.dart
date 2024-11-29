import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../common/module.dart';

typedef WarningLevelCounts = Map<WarningLevel, int>;
class ListOption {
  ListOption({required this.label, this.drugSubset});
  Widget getDescription(BuildContext context, int geneNumber) {
    return Text.rich(
      style: PharMeTheme.textTheme.labelLarge,
      TextSpan(
        children: [
          TextSpan(text: context.l10n.report_description_prefix),
          TextSpan(text: ' '),
          TextSpan(text: label, style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: context.l10n.report_gene_number(geneNumber),
            style: TextStyle(color: PharMeTheme.buttonColor),
          ),
        ],
      ),
    );
  }
  final String label;
  final List<String>? drugSubset;
}

@RoutePage()
class ReportPage extends HookWidget {
  const ReportPage({@visibleForTesting this.onlyShowWholeReport = false});

  // Currently for testing but might use in the future
  final bool onlyShowWholeReport;

  @override
  Widget build(BuildContext context) {
    final currentListOption = useState(0);
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) =>
        _buildReportPage(context, activeDrugs, currentListOption)
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
  
  Iterable<GenotypeResult> _getRelevantGenotypes(List<String>? drugSubset) {
    return drugSubset != null
      ? UserData.instance.genotypeResults!.values.filter((genotypeResult) =>
          _getAffectedDrugs(
                genotypeResult.key.value,
                drugSubset: drugSubset,
          ).isNotEmpty
        )
      : UserData.instance.genotypeResults!.values;
  }

  List<Widget> _buildGeneCards({ List<String>? drugsToFilterBy }) {
    final userGenotypes = _getRelevantGenotypes(drugsToFilterBy);
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

  Widget _maybeBuildPageIndicators(
    BuildContext context,
    Iterable<GenotypeResult> relevantGenes,
    ActiveDrugs activeDrugs,
    ListOption currentListOption,
  ) {
    final hasActiveInhibitors = relevantGenes.any(
      (genotypeResult) => activeDrugs.names.any(
        (drug) => isInhibited(genotypeResult, drug: drug)
      )
    );
    if (!hasActiveInhibitors && currentListOption.drugSubset == null) {
      return SizedBox.shrink();
    }
    var indicatorText = '';
    if (hasActiveInhibitors) {
      indicatorText = context.l10n.report_page_indicator_explanation(
        drugInteractionIndicatorName,
        drugInteractionIndicator
      );
    }
    if (currentListOption.drugSubset != null) {
      indicatorText = '$indicatorText\n\n'
        '${context.l10n.show_all_dropdown_text(
            context.l10n.report_show_all_dropdown_item,
            context.l10n.report_show_all_dropdown_items,
          )}';
    }
    return PageIndicatorExplanation(indicatorText);
  }

  Widget _buildReportPage(
    BuildContext context,
    ActiveDrugs activeDrugs,
    ValueNotifier<int> currentListOptionIndex,
  ) {
    final listOptions = onlyShowWholeReport
      ? [ListOption(label: context.l10n.report_all_medications)]
      : [
        ListOption(
          label: context.l10n.report_current_medications,
          drugSubset: activeDrugs.names,
        ),
        ListOption(label: context.l10n.report_all_medications),
      ];
    final currentListOption = listOptions[currentListOptionIndex.value];
    final geneCards = _buildGeneCards(
      drugsToFilterBy: currentListOption.drugSubset,
    );
    final relevantGenes = _getRelevantGenotypes(currentListOption.drugSubset);
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
            Padding(
              key: Key('gene-report-selection'),
              padding: EdgeInsets.only(
                top: PharMeTheme.smallSpace,
                left: PharMeTheme.smallSpace,
                bottom: PharMeTheme.smallSpace,
                right: PharMeTheme.mediumToLargeSpace,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  isDense: false,
                  value: currentListOptionIndex.value,
                  onChanged: (index) => currentListOptionIndex.value =
                    index ?? currentListOptionIndex.value,
                  icon: Padding(
                    padding: EdgeInsets.only(left: PharMeTheme.smallSpace),
                    child: ResizedIconButton(
                      size: PharMeTheme.largeSpace,
                      disabledBackgroundColor: PharMeTheme.buttonColor,
                      iconWidgetBuilder: (size) => Icon(
                        Icons.arrow_drop_down,
                        size: size,
                        color: PharMeTheme.surfaceColor,
                      ),
                    ),
                  ),
                  items: listOptions.mapIndexed(
                    (index, listOption) => DropdownMenuItem<int>(
                      value: index,
                      child: listOption.getDescription(
                        context,
                        _buildGeneCards(
                          drugsToFilterBy: listOption.drugSubset,
                        ).length
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ),
            scrollList(geneCards),
            _maybeBuildPageIndicators(
              context,
              relevantGenes,
              activeDrugs,
              currentListOption,
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
                color: PharMeTheme.buttonColor,
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
