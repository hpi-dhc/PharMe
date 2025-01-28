
import 'package:flutter/cupertino.dart';

import '../../../../common/module.dart';
import '../../../drug/widgets/tooltip_icon.dart';

class DrugSearch extends HookWidget {
  const DrugSearch({
    super.key,
    required this.showFilter,
    required this.buildDrugItems,
    required this.showDrugInteractionIndicator,
    required this.searchForDrugClass,
    required this.cubit,
    required this.state,
    required this.activeDrugs,
    this.keepPosition = false,
    this.drugActivityChangeable = false,
  });

  final bool showFilter;
  final bool searchForDrugClass;
  final bool keepPosition;
  final bool drugActivityChangeable;
  final DrugItemBuilder buildDrugItems;
  final bool showDrugInteractionIndicator;
  final DrugListCubit cubit;
  final DrugListState state;
  final ActiveDrugs activeDrugs;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final noDrugsMessage = '${context.l10n.search_no_drugs(
      showFilter
        ? context.l10n.search_no_drugs_with_filter_amendment
        : '')
    }\n\n${context.l10n.included_content_addition}';
    return DrugList(
      state: state,
      activeDrugs: activeDrugs,
      buildDrugItems: buildDrugItems,
      showDrugInteractionIndicator: showDrugInteractionIndicator,
      noDrugsMessage: noDrugsMessage,
      searchForDrugClass: searchForDrugClass,
      buildContainer: ({
        children,
        indicator,
        noDrugsMessage,
        showInactiveDrugs,
      }) => Column(
          children: [
            Padding(
              padding: EdgeInsets.all(PharMeTheme.smallSpace),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _buildSearchBarItems(
                  context,
                  searchController,
                  showInactiveDrugs: showInactiveDrugs ?? true,
                ),
              ),
            ),
            if (children != null) scrollList(
              keepPosition: keepPosition,
              children,
            ),
            if (noDrugsMessage != null) noDrugsMessage,
            if (indicator != null) indicator,
          ],
        ),
      drugActivityChangeable: drugActivityChangeable,
    );
  }

  List<Widget> _buildSearchBarItems(
    BuildContext context,
    TextEditingController searchController,
    {
      required bool showInactiveDrugs,
    }
  ) {
    return [
      Expanded(
        child: CupertinoSearchTextField(
          controller: searchController,
          onChanged: (value) {
            context.read<DrugListCubit>().search(
              query: value,
            );
          },
        ),
      ),
      SizedBox(width: PharMeTheme.smallToMediumSpace),
      TooltipIcon(searchForDrugClass
        ? context.l10n.search_page_tooltip_search
        : context.l10n.search_page_tooltip_search_no_class
      ),
      if (showFilter) ...[
        SizedBox(width: PharMeTheme.smallToMediumSpace),
        DrugFilters(
          cubit: cubit,
          state: state,
          activeDrugs: activeDrugs,
          searchForDrugClass: searchForDrugClass,
          showInactiveDrugs: showInactiveDrugs,
        ),
      ],
    ];
  }
}
