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
                                Table(
                                  columnWidths: Map.from({
                                    0: IntrinsicColumnWidth(),
                                    1: IntrinsicColumnWidth(flex: 1),
                                  }),
                                  children: [
                                    _buildRow(
                                        context.l10n.gene_page_genotype,
                                        genotypeResult.variantDisplayString(context),
                                        tooltip: context.l10n.gene_page_genotype_tooltip
                                    ),
                                    _buildPhenotypeRow(context),
                                  ],
                                ),
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
                          SizedBox(height: PharMeTheme.mediumSpace),
                          ListPageInclusionDescription(
                            type: ListPageInclusionDescriptionType.medications,
                            customPadding: EdgeInsets.zero,
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

  TableRow _buildPhenotypeRow(BuildContext context) {
    return _buildRow(
      context.l10n.gene_page_phenotype,
      possiblyAdaptedPhenotype(context, genotypeResult, drug: null),
      tooltip:
        context.l10n.gene_page_phenotype_tooltip,
    );
  }

  TableRow _buildRow(String key, String value, {String? tooltip}) =>
      TableRow(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 4, 12, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(key,
                  style: PharMeTheme.textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold)),
              if (tooltip.isNotNullOrEmpty) ...[
                SizedBox(width: PharMeTheme.smallSpace),
                TooltipIcon(tooltip!),
              ],
            ],
          ),
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 4, 0, 4), child: Text(value)),
      ]);
}
