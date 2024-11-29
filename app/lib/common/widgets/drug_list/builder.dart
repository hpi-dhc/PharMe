import '../../module.dart';

typedef DrugItemBuilder = List<Widget> Function(
  BuildContext context,
  List<Drug> drugs,
  {
    required bool showDrugInteractionIndicator,
    required String keyPrefix,
  }
);

// TODO(tamslo): https://github.com/hpi-dhc/PharMe/issues/731
class DrugList extends HookWidget {
  const DrugList({
    super.key,
    required this.state,
    required this.activeDrugs,
    this.noDrugsMessage,
    this.buildDrugItems = buildDrugCards,
    this.showDrugInteractionIndicator = false,
    this.searchForDrugClass = true,
    this.drugActivityChangeable = false,
    required this.buildContainer,
  });

  final DrugListState state;
  final ActiveDrugs activeDrugs;
  final String? noDrugsMessage;
  final DrugItemBuilder buildDrugItems;
  final bool showDrugInteractionIndicator;
  final bool searchForDrugClass;
  // if drugActivityChangeable, active medications are not filtered and repeated
  // in the "All medications" list to make searching and toggling a medication's
  // activity less confusing
  final bool drugActivityChangeable;
  final Widget Function({
    List<Widget>? children,
    Widget? indicator,
    Widget? noDrugsMessage,
  }) buildContainer;

  Widget _buildDrugList(
    BuildContext context,
    List<Drug> drugs,
    FilterState filter,
    ValueNotifier<bool?> otherDrugsExpanded,
  ) {
    final filteredDrugs = filter.filter(
      drugs,
      activeDrugs,
      searchForDrugClass: searchForDrugClass,
    ).sortedBy((drug) => drug.name);
    if (filteredDrugs.isEmpty && noDrugsMessage != null) {
      return buildContainer(noDrugsMessage: errorIndicator(noDrugsMessage!));
    }
    List<Widget>? activeDrugsList;
    // Do not show repeated active drugs when searching in medication selection
    if (drugActivityChangeable && filteredDrugs.length != drugs.length) {
      activeDrugsList = null;
    } else {
      final activeFilteredDrugs =
      filteredDrugs.filter((drug) => drug.isActive).toList();
      activeDrugsList = activeFilteredDrugs.isNotEmpty
        ? buildDrugItems(
            context,
            activeFilteredDrugs,
            showDrugInteractionIndicator: showDrugInteractionIndicator,
            keyPrefix: 'active-',
          )
        : null;
    }
    final otherDrugs = drugActivityChangeable
      ? filteredDrugs
      : filteredDrugs.filter((drug) => !drug.isActive).toList();
    final otherDrugsHeaderText = drugActivityChangeable
      ? context.l10n.drug_list_subheader_all_drugs
      : context.l10n.drug_list_subheader_other_drugs;
    final allDrugsList = buildDrugItems(
      context,
      otherDrugs,
      showDrugInteractionIndicator: showDrugInteractionIndicator,
      keyPrefix: 'other-',
    );
    final otherDrugsHeader = SubheaderDivider(
      text: '$otherDrugsHeaderText (${allDrugsList.length})',
      key: Key('header-other'),
      useLine: false,
    );
    final currentlyExpanded = otherDrugsExpanded.value ?? false;
    final currentlyEnabled = filter.query.isBlank;
    final drugLists = [
      if (activeDrugsList != null) ...[
        ListTile(
          key: Key('header-active'),
          title: SubheaderDivider(
            text: '${context.l10n.drug_list_subheader_active_drugs} '
              '(${activeDrugsList.length})',
            useLine: false,
          ),
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.zero,
        ),
        ...activeDrugsList,
      ],
      if (activeDrugsList != null && allDrugsList.isNotEmpty)
        ...[
          PrettyExpansionTile(
            title: otherDrugsHeader,
            enabled: currentlyEnabled,
            initiallyExpanded: currentlyExpanded || !currentlyEnabled,
            onExpansionChanged: (value) => otherDrugsExpanded.value = value,
            titlePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            icon: drugActivityChangeable
              ? SizedBox.shrink()
              : ResizedIconButton(
                  size: PharMeTheme.largeSpace,
                  disabledBackgroundColor: currentlyEnabled
                    ? PharMeTheme.buttonColor
                    : PharMeTheme.onSurfaceColor,
                  iconWidgetBuilder: (size) => Icon(
                    currentlyExpanded
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                    size: size,
                    color: PharMeTheme.surfaceColor,
                  ),
                ),
            children: allDrugsList,
          ),
        ],
      if (activeDrugsList == null) ...allDrugsList,
    ];
    final indicator = _maybeBuildDrugListIndicator(
      context: context,
      drugs: drugs,
      filter: filter,
      activeDrugs: activeDrugs,
      otherDrugsExpanded: currentlyExpanded,
      currentlyEnabled: currentlyEnabled,
    );
    return buildContainer(
      children: drugLists,
      indicator: indicator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final otherDrugsExpanded = useState<bool?>(null);
    return state.when(
      initial: SizedBox.shrink,
      error: () => errorIndicator(context.l10n.err_generic),
      loaded: (allDrugs, filter) {
        otherDrugsExpanded.value ??= drugActivityChangeable;
        return _buildDrugList(context, allDrugs, filter, otherDrugsExpanded);
      },
      loading: loadingIndicator,
   );
  }

  Widget _maybeBuildDrugListIndicator({
    required BuildContext context,
    required List<Drug> drugs,
    required FilterState filter,
    required ActiveDrugs activeDrugs,
    required bool otherDrugsExpanded,
    required bool currentlyEnabled,
  }) {
    var indicatorText = '';
    if (currentlyEnabled && !otherDrugsExpanded) {
      final listHelperText = context.l10n.show_all_dropdown_text(
        context.l10n.drugs_show_all_dropdown_item,
        context.l10n.drugs_show_all_dropdown_items,
      );
      indicatorText = listHelperText;
    }
    if (showDrugInteractionIndicator) {
    final filteredDrugs = filter.filter(
      drugs,
      activeDrugs,
      searchForDrugClass: searchForDrugClass,
    );
    if (filteredDrugs.any((drug) => isInhibitor(drug.name))) {
      final inhibitorText = context.l10n.search_page_indicator_explanation(
        drugInteractionIndicatorName,
        drugInteractionIndicator
      );
      if (indicatorText.isNotBlank) {
        indicatorText = '$indicatorText\n\n$inhibitorText';
      } else {
        indicatorText = inhibitorText;
      }
    }
  }
  if (indicatorText.isNotBlank) {
    return PageIndicatorExplanation(indicatorText);
  }
  return SizedBox.shrink();
  }
}
