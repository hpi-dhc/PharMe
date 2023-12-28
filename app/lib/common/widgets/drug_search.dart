
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../common/module.dart';
import '../../drug/widgets/tooltip_icon.dart';

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
    final amendment = showFilter
      ? context.l10n.search_no_drugs_with_filter_amendment
      : '';
    final noDrugsMessage = context.l10n.search_no_drugs(amendment);
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) => BlocProvider(
        create: (context) => cubit,
        child: BlocBuilder<DrugListCubit, DrugListState>(
          builder: (context, state) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CupertinoSearchTextField(
                        controller: searchController,
                        onChanged: (value) {
                          context.read<DrugListCubit>().search(query: value);
                        },
                      ),
                    ),
                    SizedBox(width: PharMeTheme.smallToMediumSpace),
                    TooltipIcon(useDrugClass
                      ? context.l10n.search_page_tooltip_search
                      : context.l10n.search_page_tooltip_search_no_class
                    ),
                    if (showFilter) buildFilter(context),
                  ]
                ),
                scrollList(
                  keepPosition: keepPosition,
                  buildDrugList(
                    context,
                    state,
                    activeDrugs,
                    buildDrugItems: buildDrugItems,
                    noDrugsMessage: noDrugsMessage,
                    drugItemsBuildParams: drugItemsBuildParams,
                    showDrugInteractionIndicator:
                      showDrugInteractionIndicator,
                    useDrugClass: useDrugClass,
                  )
                ),
                state.when(
                  initial: SizedBox.shrink,
                  loading: SizedBox.shrink,
                  loaded: (allDrugs, filter) =>
                    maybeBuildInteractionIndicator(
                      context,
                      activeDrugs,
                      allDrugs,
                      filter,
                    ),
                  error: SizedBox.shrink,
                )
              ],
            );
          }
        )
      )
    );
  }

  Widget buildFilter(BuildContext context) {
    final cubit = context.read<DrugListCubit>();
    final filter = cubit.filter;
    return FilterMenu(
      items: [
        ...WarningLevel.values
          .filter((level) => level != WarningLevel.none)
          .map((level) => FilterMenuItem(
            title: {
              WarningLevel.green: context.l10n.search_page_filter_green,
              WarningLevel.yellow: context.l10n.search_page_filter_yellow,
              WarningLevel.red: context.l10n.search_page_filter_red,
            }[level]!,
            updateSearch: ({ required isChecked }) =>
              cubit.search(showWarningLevel: { level: isChecked }),
            isChecked: filter?.showWarningLevel[level] ?? false
            )
          ),
        FilterMenuItem(
          title: context.l10n.search_page_filter_only_active,
          // Invert state as filter has opposite meaning ('only show active' vs.
          // 'show inactive')
          updateSearch: ({ required isChecked }) => cubit.search(showInactive: !isChecked),
          isChecked: !(filter?.showInactive ?? false)
        ),
        FilterMenuItem(
          title: context.l10n.search_page_filter_only_with_guidelines,
          // Invert state as filter has opposite meaning ('show only with
          // guidelines' vs. 'show with unknown warning level')
          updateSearch: ({ required isChecked }) => cubit.search(
            showWarningLevel: { WarningLevel.none: !isChecked }
          ),
          isChecked: !(filter?.showWarningLevel[WarningLevel.none] ?? false),
        )
      ],
      iconData: Icons.filter_list_rounded,
    );
  }
  Widget maybeBuildInteractionIndicator(
    BuildContext context,
    ActiveDrugs activeDrugs,
    List<Drug> drugs,
    FilterState filter,
  ) {
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
    return SizedBox.shrink();
  }
}
