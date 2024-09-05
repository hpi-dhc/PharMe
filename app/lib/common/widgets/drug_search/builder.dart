
import 'package:flutter/cupertino.dart';

import '../../../../common/module.dart';
import '../../../drug/widgets/tooltip_icon.dart';

class DrugSearch extends HookWidget {
  const DrugSearch({
    super.key,
    required this.showFilter,
    required this.buildDrugItems,
    required this.showDrugInteractionIndicator,
    required this.useDrugClass,
    required this.cubit,
    required this.state,
    required this.activeDrugs,
    this.keepPosition = false,
    this.drugItemsBuildParams,
  });

  final bool showFilter;
  final bool useDrugClass;
  final bool keepPosition;
  final List<Widget> Function(
    BuildContext context,
    List<Drug> drugs,
    {
      DrugItemsBuildParams? buildParams,
      bool showDrugInteractionIndicator,
    }
  ) buildDrugItems;
  final bool showDrugInteractionIndicator;
  final DrugListCubit cubit;
  final DrugListState state;
  final ActiveDrugs activeDrugs;
  final DrugItemsBuildParams? drugItemsBuildParams;

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
            children: [
              ..._buildSearchBarItems(context, searchController),
              if (showFilter) FilterButton(
                state,
                activeDrugs,
                useDrugClass: useDrugClass,
              ),
            ],
          ),
        ),
        scrollList(
          keepPosition: keepPosition,
          buildDrugList(
            context,
            state,
            activeDrugs,
            buildDrugItems: buildDrugItems,
            noDrugsMessage: context.l10n.search_no_drugs(
              showFilter
                ? context.l10n.search_no_drugs_with_filter_amendment
                : ''
            ),
            drugItemsBuildParams: drugItemsBuildParams,
            showDrugInteractionIndicator:
              showDrugInteractionIndicator,
            useDrugClass: useDrugClass,
          )
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
      TooltipIcon(useDrugClass
        ? context.l10n.search_page_tooltip_search
        : context.l10n.search_page_tooltip_search_no_class
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
            useDrugClass: useDrugClass,
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
