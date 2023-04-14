import '../../module.dart';

List<Widget> buildDrugList(BuildContext context, DrugListState state) =>
    state.when(
      initial: () => [Container()],
      error: () => [errorIndicator(context.l10n.err_generic)],
      loaded: (drugs, filter) => _buildDrugCards(context, drugs, filter),
      loading: () => [loadingIndicator()],
    );

List<Widget> _buildDrugCards(
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
                      .then((_) => context.read<DrugListCubit>().search()),
                  drug: drug)),
          SizedBox(height: 12)
        ]))
  ];
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
                ]),
                SizedBox(height: 4),
                if (drug.annotations.brandNames.isNotEmpty) ...[
                  SizedBox(width: 4),
                  Text(
                    '(${drug.annotations.brandNames.join(', ')})',
                    style: PharMeTheme.textTheme.titleMedium,
                  ),
                ],
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
