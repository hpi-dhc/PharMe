import '../../module.dart';

typedef DrugItemBuilder = List<Widget> Function(
  BuildContext context,
  List<Drug> drugs,
  {
    required bool showDrugInteractionIndicator,
    required String keyPrefix,
  }
);

class DrugList extends StatelessWidget {
  const DrugList({
    super.key,
    required this.state,
    required this.activeDrugs,
    this.noDrugsMessage,
    this.buildDrugItems = buildDrugCards,
    this.showDrugInteractionIndicator = false,
    this.searchForDrugClass = true,
    this.repeatMedications = false,
    this.buildContainer,
  });

  final DrugListState state;
  final ActiveDrugs activeDrugs;
  final String? noDrugsMessage;
  final DrugItemBuilder buildDrugItems;
  final bool showDrugInteractionIndicator;
  final bool searchForDrugClass;
  final bool repeatMedications;
  final Widget Function(List<Widget> children)? buildContainer;

  Widget _buildDrugList(
    BuildContext context,
    List<Drug> drugs,
    FilterState filter,
  ) {
    final filteredDrugs = filter.filter(
      drugs,
      activeDrugs,
      searchForDrugClass: searchForDrugClass,
    ).sortedBy((drug) => drug.name);
    if (filteredDrugs.isEmpty && noDrugsMessage != null) {
      return errorIndicator(noDrugsMessage!);
    }
    final activeFilteredDrugs =
      filteredDrugs.filter((drug) => drug.isActive).toList();
    final activeDrugsList = activeFilteredDrugs.isNotEmpty
      ? buildDrugItems(
          context,
          activeFilteredDrugs,
          showDrugInteractionIndicator: showDrugInteractionIndicator,
          keyPrefix: 'active-',
        )
      : null;
    final otherDrugs = repeatMedications
      ? filteredDrugs
      : filteredDrugs.filter((drug) => !drug.isActive).toList();
    final otherDrugsHeader = repeatMedications
      ? context.l10n.drug_list_subheader_all_drugs
      : context.l10n.drug_list_subheader_other_drugs;
    final allDrugsList = buildDrugItems(
      context,
      otherDrugs,
      showDrugInteractionIndicator: showDrugInteractionIndicator,
      keyPrefix: 'other-',
    );
    final drugLists = [
      if (activeDrugsList != null) ...[
        SubheaderDivider(
          text: context.l10n.drug_list_subheader_active_drugs,
          key: Key('header-active'),
          useLine: false,
        ),
        ...activeDrugsList,
      ],
      if (activeDrugsList != null) SubheaderDivider(
        text: otherDrugsHeader,
        key: Key('header-other'),
        useLine: false,
      ),
      ...allDrugsList,
    ];
    return (buildContainer != null)
      ? buildContainer!(drugLists)
      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: drugLists);
  }

  @override
  Widget build(BuildContext context) {
    return state.when(
      initial: SizedBox.shrink,
      error: () => errorIndicator(context.l10n.err_generic),
      loaded: (allDrugs, filter) => _buildDrugList(context, allDrugs, filter),
      loading: loadingIndicator,
   );
  }
}
