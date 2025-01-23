import 'package:provider/provider.dart';

import '../../common/module.dart';
import '../../drug/widgets/module.dart';

@RoutePage()
class GenePage extends HookWidget {
  GenePage(this.genotypeResult, {this.initiallyExpandFurtherMedications = false})
      : cubit = DrugListCubit(
          initialFilter:
            FilterState.forGenotypeKey(genotypeResult.key.value),
        );

  final GenotypeResult genotypeResult;
  final DrugListCubit cubit;
  final bool initiallyExpandFurtherMedications;

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) => BlocProvider(
        create: (context) => cubit,
        child: BlocBuilder<DrugListCubit, DrugListState>(
          builder: (context, state) => unscrollablePageScaffold(
            title:
              context.l10n.gene_page_headline(genotypeResult.geneDisplayString),
            body: DrugList(
              state: state,
              activeDrugs: activeDrugs,
              noDrugsMessage: context.l10n.gene_page_no_relevant_drugs,
              initiallyExpandFurtherMedications: initiallyExpandFurtherMedications,
              buildContainer: ({
                children,
                indicator,
                noDrugsMessage,
                showInactiveDrugs,
              }) =>
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: PharMeTheme.smallToMediumSpace,
                        right: PharMeTheme.smallToMediumSpace,
                        top: PharMeTheme.smallSpace,
                        bottom: PharMeTheme.smallSpace,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SubHeader(
                            context.l10n.gene_page_your_result(
                              genotypeResult.geneDisplayString,
                            ),
                            tooltip: context.l10n
                                .gene_page_name_tooltip(
                                  genotypeResult.gene,
                                ),
                          ),
                          SizedBox(height: PharMeTheme.smallToMediumSpace),
                          RoundedCard(
                            radius: PharMeTheme.mediumSpace,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildGeneResults(context),
                                if (isInhibited(genotypeResult, drug: null)) ...[
                                  SizedBox(height: PharMeTheme.smallSpace),
                                  PhenoconversionExplanation(
                                    inhibitedGenotypes: [genotypeResult],
                                    drugName: null,
                                  ),
                                ]
                            ],
                          )),
                          SizedBox(height: PharMeTheme.mediumToLargeSpace),
                          SubHeader(
                            context.l10n.gene_page_relevant_drugs,
                            tooltip: context.l10n.gene_page_relevant_drugs_tooltip(
                              genotypeResult.geneDisplayString
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (children != null) scrollList(children),
                    if (noDrugsMessage != null) noDrugsMessage,
                    if (indicator != null) indicator,
                  ]
                ),
            ),
          ),
        ),
      )
    );

  }
  
  Widget _buildGeneResults(BuildContext context) => buildTable([
    testResultTableRow(
      context,
      key: context.l10n.gene_page_genotype,
      value: genotypeResult.variantDisplayString(context),
      keyTooltip: context.l10n.gene_page_genotype_tooltip,
    ),
    phenotypeTableRow(
      context,
      key: context.l10n.gene_page_phenotype,
      genotypeResult: genotypeResult,
      drug: null,
      keyTooltip: context.l10n.gene_page_phenotype_tooltip,
    ),
  ]);
}
