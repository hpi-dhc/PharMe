import '../../module.dart';

typedef DrugItemBuilder = List<Widget> Function(
  BuildContext context,
  List<Drug> drugs,
  {
    required bool showDrugInteractionIndicator,
    required String keyPrefix,
  }
);

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
    this.buildContainer,
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
  final Widget Function(List<Widget> children)? buildContainer;

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
      return errorIndicator(noDrugsMessage!);
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
    final drugLists = [
      if (activeDrugsList != null) ...[
        ListTile(
          key: Key('header-active'),
          title: SubheaderDivider(
            text: '${context.l10n.drug_list_subheader_active_drugs} '
              '(${activeDrugsList.length})',
            useLine: false,
          ),
          trailing: drugActivityChangeable
            ? null
            : ResizedIconButton(
                size: PharMeTheme.mediumToLargeSpace,
                iconWidgetBuilder:
                  (size) => defaultIconBuilder(Icons.edit, size),
                onPressed: () => context.router.push(
                  DrugSelectionRoute(concludesOnboarding: false)
                ),
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
            enabled: filter.query.isBlank,
            initiallyExpanded: currentlyExpanded || !filter.query.isBlank,
            onExpansionChanged: (value) => otherDrugsExpanded.value = value,
            visualDensity: VisualDensity.compact,
            titlePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            children: allDrugsList,
          ),
          if (!currentlyExpanded) Padding(
            key: Key('other-hidden-instruction'),
            padding: EdgeInsets.symmetric(horizontal: PharMeTheme.smallSpace),
            child: Text(
              context.l10n.search_page_expand_help(
                otherDrugsHeaderText.toLowerCase(),
              ),
              style: PharMeTheme.textTheme.bodySmall!.copyWith(
                fontStyle: FontStyle.italic,
                color: PharMeTheme.subheaderColor,
              ),
            ),
          ),
        ],
      if (activeDrugsList == null) ...allDrugsList,
    ];
    return (buildContainer != null)
      ? buildContainer!(drugLists)
      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: drugLists);
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
}
