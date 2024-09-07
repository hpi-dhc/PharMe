import '../../module.dart';

typedef DrugItemBuilder = List<Widget> Function(
  BuildContext context,
  List<Drug> drugs,
  { required bool showDrugInteractionIndicator }
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
    this.buildContainer,
  });

  final DrugListState state;
  final ActiveDrugs activeDrugs;
  final String? noDrugsMessage;
  final DrugItemBuilder buildDrugItems;
  final bool showDrugInteractionIndicator;
  final bool searchForDrugClass;
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
    );
    if (filteredDrugs.isEmpty && noDrugsMessage != null) {
      return errorIndicator(noDrugsMessage!);
    }
    final drugItems = buildDrugItems(
      context,
      filteredDrugs.sortedBy((drug) => drug.name),
      showDrugInteractionIndicator: showDrugInteractionIndicator,
    );
    return (buildContainer != null)
      ? buildContainer!(drugItems)
      : Column(children: drugItems);
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
