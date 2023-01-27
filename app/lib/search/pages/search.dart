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
    return [
      SizedBox(height: 8),
      ...drugs.map((drug) => Column(children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: DrugCard(
                    onTap: () => context.router
                        .push(DrugRoute(drug: drug))
                        .then((_) => context.read<SearchCubit>().search()),
                    drug: drug)),
            SizedBox(height: 8)
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

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        color: warningLevel?.color ?? PharMeTheme.onSurfaceColor,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      if (warningLevel != null) ...[
                        Icon(warningLevel.icon),
                        SizedBox(width: 12)
                      ],
                      Text(
                        drug.name,
                        style: PharMeTheme.textTheme.titleMedium,
                      ),
                    ]),
                    SizedBox(height: 12),
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
        ),
      ),
    );
  }
}
