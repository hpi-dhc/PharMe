import 'package:flutter/cupertino.dart';

import '../../../common/module.dart';
import '../../common/pages/drug/widgets/tooltip_icon.dart';

class SearchPage extends HookWidget {
  SearchPage({
    Key? key,
    @visibleForTesting DrugListCubit? cubit,
  })  : cubit = cubit ?? DrugListCubit(),
        super(key: key);

  final DrugListCubit cubit;

  @override
  Widget build(BuildContext context) {
    useOnAppLifecycleStateChange((previous, current) async {
      if (current == AppLifecycleState.resumed) {
        await cubit.loadDrugs(useCache: false);
      }
    });
    final searchController = useTextEditingController();

    return BlocProvider(
        create: (context) => cubit,
        child: BlocBuilder<DrugListCubit, DrugListState>(
            builder: (context, state) {
          return pageScaffold(
            title: context.l10n.tab_drugs,
            barBottom: Row(children: [
              Expanded(
                  child: CupertinoSearchTextField(
                controller: searchController,
                onChanged: (value) {
                  context.read<DrugListCubit>().search(query: value);
                },
              )),
              SizedBox(width: 12),
              TooltipIcon(context.l10n.search_page_tooltip_search),
              buildFilter(context),
            ]),
            body: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: PharMeTheme.smallSpace,
                  horizontal: PharMeTheme.mediumSpace
                ),
                child: Text(context.l10n.search_page_asterisk_explanation),
              ),
              ...buildDrugList(context, state,
                noDrugsMessage: context.l10n.err_no_drugs,
                showInfluenceOnOtherDrugs: true
              ),
            ],
          );
        }));
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
