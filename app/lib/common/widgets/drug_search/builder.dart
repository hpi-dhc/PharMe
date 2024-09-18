
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
    this.repeatMedications = false,
  });

  final bool showFilter;
  final bool searchForDrugClass;
  final bool keepPosition;
  final bool repeatMedications;
  final DrugItemBuilder buildDrugItems;
  final bool showDrugInteractionIndicator;
  final DrugListCubit cubit;
  final DrugListState state;
  final ActiveDrugs activeDrugs;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: PharMeTheme.smallSpace,
            right: PharMeTheme.smallSpace,
            bottom: PharMeTheme.smallSpace,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _buildSearchBarItems(context, searchController),
          ),
        ),
        DrugList(
          state: state,
          activeDrugs: activeDrugs,
          buildDrugItems: buildDrugItems,
          showDrugInteractionIndicator: showDrugInteractionIndicator,
          noDrugsMessage: context.l10n.search_no_drugs(
            showFilter
              ? context.l10n.search_no_drugs_with_filter_amendment
              : ''
          ),
          searchForDrugClass: searchForDrugClass,
          buildContainer:
            (children) => scrollList(keepPosition: keepPosition, children),
          repeatMedicationsWhenNotFiltered: repeatMedications,
        ),
        _maybeBuildInteractionIndicator(context, state, activeDrugs)
          ?? SizedBox.shrink(),
      ],
    );
  }

  List<Widget> _buildSearchBarItems(
    BuildContext context,
    TextEditingController searchController,
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
      if (showFilter) DrugFilters(
        cubit: cubit,
        state: state,
        activeDrugs: activeDrugs,
        searchForDrugClass: searchForDrugClass,
      ),
    ];
  }

  Widget? _maybeBuildInteractionIndicator(
    BuildContext context,
    DrugListState state,
    ActiveDrugs activeDrugs,
  ) {
    return state.whenOrNull(
      loaded: (drugs, filter) {
        if (showDrugInteractionIndicator) {
          final filteredDrugs = filter.filter(
            drugs,
            activeDrugs,
            searchForDrugClass: searchForDrugClass,
          );
          if (filteredDrugs.any((drug) => isInhibitor(drug.name))) {
            return PageIndicatorExplanation(
              context.l10n.search_page_indicator_explanation(
                drugInteractionIndicatorName,
                drugInteractionIndicator
              ),
            );
          }
        }
        return null;
      }
    );
  }
}
