import 'package:flutter/cupertino.dart';

import '../../../common/module.dart';
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
                IconButton(
                    onPressed: () => context.read<SearchCubit>().toggleFilter(),
                    icon: PharMeTheme.starIcon(
                        isStarred: context.read<SearchCubit>().filterStarred)),
              ]),
              body: state.when(
                initial: () => [Container()],
                error: () => [errorIndicator(context.l10n.err_generic)],
                loaded: (_, drugs) => _buildDrugsList(context, drugs),
                loading: () => [loadingIndicator()],
              ));
        }));
  }

  List<Widget> _buildDrugsList(BuildContext context, List<Drug> drugs) {
    if (drugs.isEmpty && context.read<SearchCubit>().filterStarred) {
      return [errorIndicator(context.l10n.err_no_starred_drugs)];
    }
    return [
      SizedBox(height: 8),
      ...drugs.map((drug) => Column(children: [
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
    final warningLevel = drug.highestWarningLevel();

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
                  Text(
                    drug.name,
                    style: PharMeTheme.textTheme.titleMedium,
                  ),
                  if (warningLevel != null) ...[
                    SizedBox(width: 8),
                    Icon(warningLevel.icon),
                  ],
                ]),
                SizedBox(height: 8),
                Text(
                  drug.annotations.indication,
                  style: PharMeTheme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded),
        ],
      ),
    );
  }
}
