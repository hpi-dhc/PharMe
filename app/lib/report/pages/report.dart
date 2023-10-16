import '../../common/module.dart';

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return unscrollablePageScaffold(
      title: context.l10n.tab_report,
      body: Column(
        children: [
          scrollList(
            UserData.instance.lookups!.values.map((phenotype) =>
              Column(children: [
                GeneCard(phenotype),
                SizedBox(height: 8)
              ])
            ).toList()),
          drugInteractionExplanation(context),
        ]
      )
    );
  }

  Widget drugInteractionExplanation(BuildContext context) {
    return Column(children: [
      SizedBox(height: PharMeTheme.smallSpace),
      Text(
        context.l10n.report_page_indicator_explanation(
          drugInteractionIndicatorName,
          drugInteractionIndicator
        )
      ),
    ]);
  }
}

class GeneCard extends StatelessWidget {
  const GeneCard(this.phenotype);

  final CpicPhenotype phenotype;

  @override
  Widget build(BuildContext context) {
    final phenotypeInformation = UserData.phenotypeFor(
      phenotype.geneSymbol,
      context,
    );
    final phenotypeText = phenotypeInformation.adaptionText.isNullOrBlank
      ? phenotypeInformation.phenotype!
      : '${phenotypeInformation.phenotype}$drugInteractionIndicator';
    return RoundedCard(
      onTap: () => context.router.push(GeneRoute(phenotype: phenotype)),
      padding: EdgeInsets.all(8),
      radius: 16,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phenotype.geneSymbol,
                style: PharMeTheme.textTheme.titleMedium
              ),
              SizedBox(height: 8),
              Text(
                phenotypeText,
                  style: PharMeTheme.textTheme.titleSmall),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded),
      ]),
    );
  }
}
