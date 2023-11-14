
import 'package:flutter/cupertino.dart';

import '../../../common/module.dart';
import '../../common/pages/drug/widgets/tooltip_icon.dart';

class DrugSearch extends HookWidget {
  DrugSearch({
    Key? key,
    required this.showFilter,
    required this.buildDrugItems,
    required this.showDrugInteractionIndicator,
    this.drugItemsBuildParams,
    DrugListCubit? cubit,
  })  : cubit = cubit ?? DrugListCubit(),
        super(key: key);

  final bool showFilter;
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
    return BlocProvider(
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
                    TooltipIcon(context.l10n.search_page_tooltip_search),
                    if (showFilter) buildFilter(context),
                  ]
                ),
                SizedBox(height: PharMeTheme.smallSpace),
                scrollList(
                  buildDrugList(
                    context,
                    state,
                    buildDrugItems: buildDrugItems,
                    noDrugsMessage: noDrugsMessage,
                    drugItemsBuildParams: drugItemsBuildParams,
                    showDrugInteractionIndicator:
                      showDrugInteractionIndicator,
                  )
                ),
                ..._maybeShowDrugInteractionExplanation(context),
              ],
            );
        }
      )
    );
  }

  List<Widget> _maybeShowDrugInteractionExplanation(BuildContext context) {
    if (!showDrugInteractionIndicator) return [];
    return [
      SizedBox(height: PharMeTheme.smallSpace),
      Text(
        context.l10n.search_page_indicator_explanation(
          drugInteractionIndicatorName,
          drugInteractionIndicator
        )
      ),
    ];
  }

  Widget buildFilter(BuildContext context) {
    final cubit = context.read<DrugListCubit>();
    final filter = cubit.filter;
    return ContextMenu(
      items: [
        ContextMenuCheckmark(
          label: context.l10n.search_page_filter_only_active,
          // Invert state as filter has opposite meaning ('only show active' vs.
          // 'show inactive')
          setState: (state) => cubit.search(showInactive: !state),
          initialState: filter != null && !filter.showInactive),
        ...WarningLevel.values.filter((level) => level != WarningLevel.none)
          .map((level) => ContextMenuCheckmark(
            label: {
              WarningLevel.green: context.l10n.search_page_filter_green,
              WarningLevel.yellow: context.l10n.search_page_filter_yellow,
              WarningLevel.red: context.l10n.search_page_filter_red,
            }[level]!,
            setState: (state) => cubit.search(showWarningLevel: {level: state}),
            initialState: filter?.showWarningLevel[level] ?? false
            )
          ),
        ContextMenuCheckmark(
          label: context.l10n.search_page_filter_only_with_guidelines,
          // Invert state as filter has opposite meaning ('show only with
          // guidelines' vs. 'show with unknown warning level')
          setState: (state) => cubit.search(
            showWarningLevel: {WarningLevel.none: !state}
          ),
          initialState: filter != null &&
            !filter.showWarningLevel[WarningLevel.none]!,)
      ],
      child: Padding(
          padding: EdgeInsets.all(8), child: Icon(Icons.filter_list_rounded)),
    );
  }
}
