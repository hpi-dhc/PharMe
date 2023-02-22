import 'package:flutter/cupertino.dart';

import '../../../common/module.dart';
import '../../common/pages/drug/widgets/tooltip_icon.dart';
import 'cubit.dart';

class SearchPage extends HookWidget {
  const SearchPage({
    Key? key,
    @visibleForTesting this.cubit,
  }) : super(key: key);

  final SearchCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();

    return BlocProvider(
        create: (context) => cubit ?? SearchCubit(),
        child: BlocBuilder<SearchCubit, SearchState>(builder: (context, state) {
          return pageScaffold(
              title: context.l10n.tab_drugs,
              barBottom: Row(children: [
                Expanded(
                    child: CupertinoSearchTextField(
                  controller: searchController,
                  onChanged: (value) {
                    context.read<SearchCubit>().search(query: value);
                  },
                )),
                SizedBox(width: 12),
                TooltipIcon(context.l10n.search_page_tooltip_search),
                buildFilter(context.read<SearchCubit>()),
              ]),
              body: state.when(
                initial: () => [Container()],
                error: () => [errorIndicator(context.l10n.err_generic)],
                loaded: (drugs, filter) =>
                    _buildDrugsList(context, drugs, filter),
                loading: () => [loadingIndicator()],
              ));
        }));
  }

  Widget buildFilter(SearchCubit cubit) {
    final filter = cubit.filter;
    print('build filter');
    return ContextMenu(
      items: [
        ContextMenuCheckmark(
            label: 'show inactive',
            setState: () => cubit.search(toggleInactive: true),
            icon: _checkmark(isEnabled: filter?.showInactive)),
        ...WarningLevel.values.map((level) => ContextMenuCheckmark(
            label: 'placeholder',
            setState: () => cubit.search(toggleWarningLevel: level),
            icon: _checkmark(isEnabled: filter?.showWarningLevel[level])))
      ],
      child: Padding(
          padding: EdgeInsets.all(8), child: Icon(Icons.filter_list_rounded)),
    );
  }

  IconData? _checkmark({required bool? isEnabled}) =>
      isEnabled ?? false ? Icons.check_rounded : null;

  List<Widget> _buildDrugsList(
      BuildContext context, List<Drug> drugs, FilterState filter) {
    final filteredDrugs = filter.filter(drugs);
    if (filteredDrugs.isEmpty) {
      return [errorIndicator(context.l10n.err_no_drugs)];
    }
    return [
      SizedBox(height: 8),
      ...filteredDrugs.map((drug) => Column(children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: DrugCard(
                    onTap: () => context.router
                        .push(DrugRoute(drug: drug))
                        .then((_) => context.read<SearchCubit>().search()),
                    drug: drug)),
            SizedBox(height: 12)
          ]))
    ];
  }
}

class DrugCard extends StatelessWidget {
  const DrugCard({
    required this.onTap,
    required this.drug,
  });

  final VoidCallback onTap;
  final Drug drug;

  @override
  Widget build(BuildContext context) {
    final warningLevel = drug.userGuideline()?.annotations.warningLevel;

    return RoundedCard(
      onTap: onTap,
      padding: EdgeInsets.all(8),
      radius: 16,
      color: warningLevel?.color ?? PharMeTheme.onSurfaceColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(warningLevel?.icon ?? Icons.help_outline_rounded),
                  SizedBox(width: 4),
                  Text(
                    drug.name.capitalize(),
                    style: PharMeTheme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (drug.annotations.brandNames.isNotEmpty) ...[
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '(${drug.annotations.brandNames.join(', ')})',
                        style: PharMeTheme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ]),
                SizedBox(height: 8),
                Text(
                  drug.annotations.drugclass,
                  style: PharMeTheme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
