import '../../common/module.dart';
import '../../common/pages/drug/widgets/sub_header.dart';
import '../../common/pages/drug/widgets/tooltip_icon.dart';

class GenePage extends HookWidget {
  GenePage(this.phenotype)
      : cubit = DrugListCubit(
          initialFilter: FilterState.forGene(phenotype.geneSymbol),
        );

  final CpicPhenotype phenotype;
  final DrugListCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit,
      child: BlocBuilder<DrugListCubit, DrugListState>(
        builder: (context, state) => pageScaffold(
          title: context.l10n.gene_page_headline(phenotype.geneSymbol),
          body: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubHeader(
                    context.l10n.gene_page_your_variant(phenotype.geneSymbol),
                    tooltip: context.l10n
                        .gene_page_name_tooltip(phenotype.geneSymbol),
                  ),
                  SizedBox(height: 12),
                  RoundedCard(
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
                                phenotype.genotype,
                                tooltip: context.l10n.gene_page_genotype_tooltip
                            ),
                            _buildRow(context.l10n.gene_page_phenotype,
                                UserData.phenotypeFor(phenotype.geneSymbol)!,
                                tooltip:
                                  context.l10n.gene_page_phenotype_tooltip
                            ),
                          ],
                        ),
                        if (drugInhibitors.containsKey(phenotype.geneSymbol))
                          ...[
                            SizedBox(height: PharMeTheme.smallSpace),
                            Text(context.l10n.gene_page_inhibitor_drugs),
                            SizedBox(height: PharMeTheme.smallSpace),
                            Text(drugInhibitors[phenotype.geneSymbol]!.keys
                              .join(', ')
                            ),
                          ],
                    ],
                  )),
                  SizedBox(height: 12),
                  SubHeader(context.l10n.gene_page_affected_drugs,
                      tooltip: context.l10n.gene_page_affected_drugs_tooltip),
                  ...buildDrugList(context, state,
                      noDrugsMessage: context.l10n.gene_page_no_affected_drugs)
                ],
              ),
            ),
          ],
        ),
      ),
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
