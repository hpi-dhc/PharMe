import '../../../module.dart';

List<Widget> buildDrugCards(
  BuildContext context,
  List<Drug> drugs,
  { Map? buildParams }
) {
  int warningLevelSeverity(Drug drug) {
      final warningLevel = drug.userGuideline()?.annotations.warningLevel
        ?? WarningLevel.none;
      return warningLevel.severity;
    }
  drugs.sort((drugA, drugB) {
    final warningLevelComparison = -warningLevelSeverity(drugA)
      .compareTo(warningLevelSeverity(drugB));
    if (warningLevelComparison == 0) {
      return drugA.name.compareTo(drugB.name);
    }
    return warningLevelComparison;
  });
  return [
    SizedBox(height: 8),
    ...drugs.map((drug) => Column(children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: PharMeTheme.smallSpace),
              child: DrugCard(
                  onTap: () => context.router
                      .push(DrugRoute(drug: drug))
                      .then((_) => context.read<DrugListCubit>().search()),
                  drug: drug,
              )
          ),
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
    var drugName = drug.name.capitalize();
    if (isInhibitor(drug)) drugName = '$drugName *';

    return RoundedCard(
      onTap: onTap,
      padding: EdgeInsets.all(8),
      radius: 16,
      color: warningLevel?.color ?? PharMeTheme.indeterminateColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(warningLevel?.icon ?? indeterminateIcon),
                  SizedBox(width: 4),
                  Text(
                    drugName,
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
