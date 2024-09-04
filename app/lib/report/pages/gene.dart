import 'package:provider/provider.dart';

import '../../common/module.dart';
import '../../drug/widgets/module.dart';

@RoutePage()
class GenePage extends HookWidget {
  GenePage(this.genotypeResult)
      : cubit = DrugListCubit(
          initialFilter:
            FilterState.forGenotypeKey(genotypeResult.key.value),
        );

  final GenotypeResult genotypeResult;
  final DrugListCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) => BlocProvider(
        create: (context) => cubit,
        child: BlocBuilder<DrugListCubit, DrugListState>(
          builder: (context, state) => pageScaffold(
            title:
              context.l10n.gene_page_headline(genotypeResult.geneDisplayString),
            body: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: PharMeTheme.smallToMediumSpace,
                  vertical: PharMeTheme.mediumSpace
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
                                  genotypeResult.variantDisplayString,
                                  tooltip: context.l10n.gene_page_genotype_tooltip
                              ),
                              _buildPhenotypeRow(context),
                            ],
                          ),
                          if (isInhibited(genotypeResult)) ...[
                            SizedBox(height: PharMeTheme.smallSpace),
                            buildDrugInteractionInfo(
                              context,
                              genotypeResult,
                            ),
                          ]
                      ],
                    )),
                    SizedBox(height: PharMeTheme.smallToMediumSpace),
                    SubHeader(
                      context.l10n.gene_page_relevant_drugs,
                      tooltip: context.l10n.gene_page_relevant_drugs_tooltip(
                        genotypeResult.geneDisplayString
                      ),
                    ),
                    SizedBox(height: PharMeTheme.smallSpace),
                    ...buildDrugList(context, state, activeDrugs,
                        noDrugsMessage: context.l10n.gene_page_no_relevant_drugs)
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  TableRow _buildPhenotypeRow(BuildContext context) {
    return _buildRow(
      context.l10n.gene_page_phenotype,
      possiblyAdaptedPhenotype(genotypeResult),
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
                SizedBox(width: 4),
                TooltipIcon(tooltip!),
              ],
            ],
          ),
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 4, 0, 4), child: Text(value)),
      ]);
}
