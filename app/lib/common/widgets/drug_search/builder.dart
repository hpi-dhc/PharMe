
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../common/module.dart';
import '../../../drug/widgets/tooltip_icon.dart';

class DrugSearch extends HookWidget {
  DrugSearch({
    super.key,
    required this.showFilter,
    required this.buildDrugItems,
    required this.showDrugInteractionIndicator,
    this.useDrugClass = true,
    this.keepPosition = false,
    this.drugItemsBuildParams,
    DrugListCubit? cubit,
  })  : cubit = cubit ?? DrugListCubit();

  final bool showFilter;
  final bool useDrugClass;
  final bool keepPosition;
  final List<Widget> Function(
    BuildContext context,
    List<Drug> drugs,
    {
      Map? buildParams,
      bool showDrugInteractionIndicator,
    }
  ) buildDrugItems;
  final bool showDrugInteractionIndicator;
  final DrugListCubit cubit;
  final Map? drugItemsBuildParams;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) => BlocProvider(
        create: (context) => cubit,
        child: BlocBuilder<DrugListCubit, DrugListState>(
          builder: (context, state) {
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
                      if (showFilter) FilterButton(),
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
        )
      )
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
