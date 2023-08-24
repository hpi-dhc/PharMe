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
  return drugs.map((drug) => DrugCard(
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
  });

  final VoidCallback onTap;
  final Drug drug;
  final bool showDrugInteractionIndicator;

  @override
  Widget build(BuildContext context) {
    final warningLevel = drug.userGuideline()?.annotations.warningLevel;
    final drugName = formatDrugName(drug, showDrugInteractionIndicator);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: PharMeTheme.smallSpace / 2),
      child: RoundedCard(
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
      ),
    );
  }
}
