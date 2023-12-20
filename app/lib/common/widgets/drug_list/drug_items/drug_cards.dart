import '../../../module.dart';
import 'utils.dart';

List<Widget> buildDrugCards(
  BuildContext context,
  List<Drug> drugs,
  {
    Map? buildParams,
    bool showDrugInteractionIndicator = false,
  }
) {
  drugs.sort((drugA, drugB) {
    final warningLevelComparison = -drugA.warningLevel.severity
      .compareTo(drugB.warningLevel.severity);
    if (warningLevelComparison == 0) {
      return drugA.name.compareTo(drugB.name);
    }
    return warningLevelComparison;
  });
  return drugs.map((drug) => DrugCard(
      key: Key('drug-card-${drug.name}'),
      onTap: () => context.router
          .push(DrugRoute(drug: drug))
          .then((_) => context.read<DrugListCubit>().search()),
      drug: drug,
      showDrugInteractionIndicator: showDrugInteractionIndicator,
    )
  ).toList();
}

class DrugCard extends StatelessWidget {
  const DrugCard({
    required this.onTap,
    required this.drug,
    required this.showDrugInteractionIndicator,
    super.key,
  });

  final VoidCallback onTap;
  final Drug drug;
  final bool showDrugInteractionIndicator;

  @override
  Widget build(BuildContext context) {
    final drugName = formatDrugName(drug, showDrugInteractionIndicator);
    return RoundedCard(
        onTap: onTap,
        innerPadding: EdgeInsets.all(PharMeTheme.smallSpace),
        radius: 16,
        color: drug.warningLevel.color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(drug.warningLevel.icon),
                    SizedBox(width: 4),
                    Text(
                      drugName,
                      style: PharMeTheme.textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ]),
                  SizedBox(height: PharMeTheme.smallSpace / 2),
                  if (drug.annotations.brandNames.isNotEmpty) ...[
                    SizedBox(width: PharMeTheme.smallSpace / 2),
                    Text(
                      '(${drug.annotations.brandNames.join(', ')})',
                      style: PharMeTheme.textTheme.titleMedium,
                    ),
                  ],
                  SizedBox(height: PharMeTheme.smallSpace * 0.75),
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
