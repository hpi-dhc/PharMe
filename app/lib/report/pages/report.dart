import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../common/module.dart';

typedef WarningLevelCounts = Map<WarningLevel, int>;

enum SortOption {
  alphabetical,
  warningSeverity,
}

@RoutePage()
class ReportPage extends HookWidget {
  const ReportPage({@visibleForTesting this.allGenesInitiallyExpanded = false});

  final bool allGenesInitiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final allGenesExpanded = useState(allGenesInitiallyExpanded);
    // Not changeable yet in UI!
    final currentSortOption = useState(SortOption.alphabetical);
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) =>
        _buildReportPage(
          context,
          activeDrugs,
          allGenesExpanded,
          currentSortOption,
        )
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
  
  Iterable<GenotypeResult> _getRelevantGenotypes(
    List<String>? drugSubset,
  ) {
    if (UserData.instance.genotypeResults == null) return [];
    final allGenotypeResults = UserData.instance.genotypeResults!.values;
    if (drugSubset == null) return allGenotypeResults;
    return allGenotypeResults.filter(
      (genotypeResult) => _getAffectedDrugs(
        genotypeResult.key.value,
        drugSubset: drugSubset,
      ).isNotEmpty
    );
  }

  List<Widget> _buildGeneCards({
    required SortOption currentSortOption,
    List<String>? drugsToFilterBy,
    required String keyPostfix,
  }) {
    final userGenotypes = _getRelevantGenotypes(
      drugsToFilterBy,
    );
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
    if (currentSortOption == SortOption.warningSeverity) {
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
    }
    return sortedGenotypes.map((genotypeResult) =>
      GeneCard(
        genotypeResult,
        warningLevelCounts[genotypeResult.key.value]!,
        key: Key('gene-card-${genotypeResult.key.value}-$keyPostfix'),
        useColors: false,
      )
    ).toList();
  }

  Widget _maybeBuildPageIndicators(
    BuildContext context,
    ActiveDrugs activeDrugs,
    { required bool allGenesVisible }
  ) {
    final drugsToFilterBy = allGenesVisible ? null : activeDrugs.names;
    final relevantGenes = _getRelevantGenotypes(drugsToFilterBy);
    final hasActiveInhibitors = relevantGenes.any(
      (genotypeResult) => activeDrugs.names.any(
        (drug) => isInhibited(genotypeResult, drug: drug)
      )
    );
    if (!hasActiveInhibitors && drugsToFilterBy == null) {
      return SizedBox.shrink();
    }
    var indicatorText = '';
    if (drugsToFilterBy != null) {
      final listHelperText = context.l10n.show_all_dropdown_text(
        context.l10n.report_show_all_dropdown_item,
        context.l10n.report_dropdown_position,
        context.l10n.report_show_all_dropdown_items,
      );
      indicatorText = listHelperText;
    }
    if (hasActiveInhibitors) {
      final inhibitorText = context.l10n.report_page_indicator_explanation(
        drugInteractionIndicatorName,
        drugInteractionIndicator
      );
      if (indicatorText.isNotBlank) {
        indicatorText = '$indicatorText\n\n$inhibitorText';
      } else {
        indicatorText = inhibitorText;
      }
    }
    return PageIndicatorExplanation(indicatorText);
  }

  Widget _buildReportPage(
    BuildContext context,
    ActiveDrugs activeDrugs,
    ValueNotifier<bool> allGenesExpanded,
    ValueNotifier<SortOption> currentSortOption,
  ) {
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
              _buildReportLists(
                context,
                activeDrugs,
                allGenesExpanded,
                currentSortOption,
              ),
            ),
            _maybeBuildPageIndicators(
              context,
              activeDrugs,
              allGenesVisible: allGenesExpanded.value,
            ),
          ]
        )
      ),
    );
  }

  Widget _listDescription(
    BuildContext context,
    String label,
    { required List<String>? drugsToFilterBy }
  ) {
    final genotypes = _getRelevantGenotypes(
      drugsToFilterBy,
    );
    final affectedDrugs = genotypes.flatMap(
      (genotypeResult) => _getAffectedDrugs(
        genotypeResult.key.value,
        drugSubset: drugsToFilterBy,
      )
    ).toSet();
    return Padding(
      key: Key('list-description-$label'),
      padding: EdgeInsets.symmetric(
        vertical: PharMeTheme.mediumSpace,
        horizontal: PharMeTheme.smallSpace,
      ),
      child: Text.rich(
        style: subheaderDividerStyle(),
        TextSpan(
          children: [
            TextSpan(text: context.l10n.report_description_prefix),
            TextSpan(text: ' '),
            TextSpan(text: label, style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' '),
            TextSpan(
              text: '(${context.l10n.report_gene_number(genotypes.length)}, '
                '${context.l10n.report_medication_number(affectedDrugs.length)})',
              style: TextStyle(color: PharMeTheme.buttonColor),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReportLists(
    BuildContext context,
    ActiveDrugs activeDrugs,
    ValueNotifier<bool> allGenesExpanded,
    ValueNotifier<SortOption> currentSortOption,
  ) {
    final currentMedicationGenes = _buildGeneCards(
      currentSortOption: currentSortOption.value,
      drugsToFilterBy: activeDrugs.names,
      keyPostfix: 'current-medications',
    );
    final allMedicationGenesHeader =  _listDescription(
      context,
      context.l10n.report_all_medications,
      drugsToFilterBy: null,
    );
    final allMedicationGenes = _buildGeneCards(
      currentSortOption: currentSortOption.value,
      drugsToFilterBy: null,
      keyPostfix: 'all-medications',
    );
    if (currentMedicationGenes.isEmpty) {
      return [
        allMedicationGenesHeader,
        ...allMedicationGenes,
      ];
    }
    return [
      _listDescription(
        context,
        context.l10n.report_current_medications,
        drugsToFilterBy: activeDrugs.names,
      ),
      ...currentMedicationGenes,
      PrettyExpansionTile(
        title: allMedicationGenesHeader,
        initiallyExpanded: allGenesExpanded.value,
        onExpansionChanged: (value) => allGenesExpanded.value = value,
        titlePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        icon: ResizedIconButton(
          size: PharMeTheme.largeSpace,
          disabledBackgroundColor: PharMeTheme.buttonColor,
          iconWidgetBuilder: (size) => Icon(
            allGenesExpanded.value
              ? Icons.arrow_drop_up
              : Icons.arrow_drop_down,
            size: size,
            color: PharMeTheme.surfaceColor,
          ),
        ),
        children: allMedicationGenes,
      ),
    ];
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
