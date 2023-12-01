import '../../module.dart';
import 'drug_items/drug_cards.dart';

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
        Map? buildParams,
        bool showDrugInteractionIndicator,
      }
    ) buildDrugItems = buildDrugCards,
    bool showDrugInteractionIndicator = false,
    bool useDrugClass = true,
    Map? drugItemsBuildParams,
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
