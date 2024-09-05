import '../../module.dart';

class DrugItemsBuildParams {
  DrugItemsBuildParams({required this.isEditable, required this.setActivity});

  final bool isEditable;
  final SetDrugActivityFunction setActivity;
}

List<Widget> buildDrugList(
  BuildContext context,
  DrugListState state,
  ActiveDrugs activeDrugs,
  {
    String? noDrugsMessage,
    List<Widget> Function(
      BuildContext context,
      List<Drug> drugs,
      {
        DrugItemsBuildParams? buildParams,
        bool showDrugInteractionIndicator,
      }
    ) buildDrugItems = buildDrugCards,
    bool showDrugInteractionIndicator = false,
    bool useDrugClass = true,
    DrugItemsBuildParams? drugItemsBuildParams,
  }
) {
  List<Widget> buildDrugList(
    List<Drug> drugs,
    FilterState filter,
  ) {
    final filteredDrugs = filter.filter(
      drugs,
      activeDrugs,
      useDrugClass: useDrugClass,
    );
    if (filteredDrugs.isEmpty && noDrugsMessage != null) {
      return [errorIndicator(noDrugsMessage)];
    }
    return buildDrugItems(
      context,
      filteredDrugs,
      buildParams: drugItemsBuildParams,
      showDrugInteractionIndicator: showDrugInteractionIndicator,
    );
  }
  return state.when(
    initial: () => [Container()],
    error: () => [errorIndicator(context.l10n.err_generic)],
    loaded: buildDrugList,
    loading: () => [loadingIndicator()],
  );
}
