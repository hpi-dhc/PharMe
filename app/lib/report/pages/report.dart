import '../../common/module.dart';

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return pageScaffold(title: context.l10n.tab_report, body: [
      SizedBox(height: 8),
      ...UserData.instance.lookups!.values
          .map((phenotype) => Column(children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: GeneCard(phenotype)),
                SizedBox(height: 8)
              ]))
          .toList()
    ]);
  }
}

class GeneCard extends StatelessWidget {
  const GeneCard(this.phenotype);

  final CpicPhenotype phenotype;

  @override
  Widget build(BuildContext context) => RoundedCard(
      padding: EdgeInsets.all(8),
      radius: 16,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(phenotype.geneSymbol,
                  style: PharMeTheme.textTheme.titleMedium),
              SizedBox(height: 8),
              Text(phenotype.phenotype,
                  style: PharMeTheme.textTheme.titleSmall),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded),
      ]));
}
