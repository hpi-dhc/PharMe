import '../../common/module.dart';
import '../../common/utilities/guideline_utils.dart';

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hasActiveInhibitors = UserData.instance.activeDrugNames != null &&
      UserData.instance.activeDrugNames!.any(isInhibitor);
    final guidelineGenes = getGuidelineGenes();

    final notTestedString = context.l10n.general_not_tested;
    final userPhenotypes = guidelineGenes.map(
      (geneSymbol) => UserData.instance.lookups![geneSymbol] ??
      CpicPhenotype(
        geneSymbol: geneSymbol,
        phenotype: notTestedString,
        genotype: notTestedString,
        lookupkey: notTestedString
      )
    );
    return unscrollablePageScaffold(
      title: context.l10n.tab_report,
      body: Column(
        children: [
          scrollList(
            userPhenotypes.map((phenotype) =>
              Column(children: [
                GeneCard(phenotype),
                SizedBox(height: 8)
              ])
            ).toList()),
          if (hasActiveInhibitors) drugInteractionExplanation(context),
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
      ? phenotypeInformation.phenotype
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
