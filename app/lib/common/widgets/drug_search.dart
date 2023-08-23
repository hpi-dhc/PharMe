
import 'package:flutter/cupertino.dart';

import '../../../common/module.dart';
import '../../common/pages/drug/widgets/tooltip_icon.dart';

class DrugSearch extends HookWidget {
  DrugSearch({
    Key? key,
    required this.showFilter,
    required this.buildDrugItems,
    this.drugItemsBuildParams,
    DrugListCubit? cubit,
  })  : cubit = cubit ?? DrugListCubit(),
        super(key: key);

  final bool showFilter;
  final List<Widget> Function(
    BuildContext context,
    List<Drug> drugs,
    { Map? buildParams }
  ) buildDrugItems;
  final DrugListCubit cubit;
  final Map? drugItemsBuildParams;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final noDrugsMessage = showFilter ?
      context.l10n.search_no_drugs(' or filters right to the search bar') :
      context.l10n.search_no_drugs('');
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
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: PharMeTheme.smallSpace / 2,
                    child: ListView(
                      padding: EdgeInsets.only(
                      right: PharMeTheme.smallSpace * 1.5
                      // right: 0
                    ),
                      children: buildDrugList(
                        context,
                        state,
                        buildDrugItems: buildDrugItems,
                        noDrugsMessage: noDrugsMessage,
                        drugItemsBuildParams: drugItemsBuildParams,
                      ),
                    ),
                  ),
                ),
              ],
            );
        }
      )
    );
  }

  Widget buildFilter(BuildContext context) {
    final cubit = context.read<DrugListCubit>();
    final filter = cubit.filter;
    return ContextMenu(
      items: [
        ContextMenuCheckmark(
            label: context.l10n.search_page_filter_inactive,
            setState: (state) => cubit.search(showInactive: state),
            initialState: filter?.showInactive ?? false),
        ...WarningLevel.values.map((level) => ContextMenuCheckmark(
            label: {
              WarningLevel.green: context.l10n.search_page_filter_green,
              WarningLevel.yellow: context.l10n.search_page_filter_yellow,
              WarningLevel.red: context.l10n.search_page_filter_red,
              WarningLevel.none: context.l10n.search_page_filter_gray,
            }[level]!,
            setState: (state) => cubit.search(showWarningLevel: {level: state}),
            initialState: filter?.showWarningLevel[level] ?? false))
      ],
      child: Padding(
          padding: EdgeInsets.all(8), child: Icon(Icons.filter_list_rounded)),
    );
  }
}
