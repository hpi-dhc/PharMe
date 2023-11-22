import 'package:provider/provider.dart';

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
    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) => BlocProvider(
        create: (context) => cubit,
        child: BlocBuilder<DrugListCubit, DrugListState>(
          builder: (context, state) => pageScaffold(
            title: context.l10n.gene_page_headline(phenotype.geneSymbol),
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
                      context.l10n.gene_page_your_variant(phenotype.geneSymbol),
                      tooltip: context.l10n
                          .gene_page_name_tooltip(phenotype.geneSymbol),
                    ),
                    SizedBox(height: PharMeTheme.smallToMediumSpace),
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
                                  UserData.phenotypeFor(
                                    phenotype.geneSymbol,
                                    context,
                                  ).phenotype,
                                  tooltip:
                                    context.l10n.gene_page_phenotype_tooltip
                              ),
                            ],
                          ),
                          if (inhibitableGenes.contains(phenotype.geneSymbol))
                            ...buildDrugInteractionInfo(
                              context,
                              phenotype.geneSymbol,
                            ),
                      ],
                    )),
                    SizedBox(height: PharMeTheme.smallToMediumSpace),
                    SubHeader(context.l10n.gene_page_affected_drugs,
                        tooltip: context.l10n.gene_page_affected_drugs_tooltip),
                    SizedBox(height: PharMeTheme.smallSpace),
                    ...buildDrugList(context, state, activeDrugs,
                        noDrugsMessage: context.l10n.gene_page_no_affected_drugs)
                  ],
                ),
              ),
            ],
          ),
        ),
      )
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

  List<Widget> buildDrugInteractionInfo(BuildContext context, String gene) {
    final phenotypeInformation = UserData.phenotypeFor(gene, context);
    if (phenotypeInformation.adaptionText.isNotNullOrBlank) {
      final furtherInhibitors = inhibitorsFor(gene).filter((drugName) =>
        !UserData.activeInhibitorsFor(gene).contains(drugName)
      );
      var phenotypeInformationText = formatAsSentence(
        phenotypeInformation.adaptionText!
      );
      if (phenotypeInformation.overwrittenPhenotype.isNotNullOrBlank) {
        phenotypeInformationText = '$phenotypeInformationText ${
          formatAsSentence(context.l10n.drugs_page_original_phenotype(
            phenotypeInformation.overwrittenPhenotype!
          ))}';
      }
      return [
        SizedBox(height: PharMeTheme.smallSpace),
        Text(phenotypeInformationText),
        SizedBox(height: PharMeTheme.smallSpace),
        Text(context.l10n.gene_page_further_inhibitor_drugs),
        SizedBox(height: PharMeTheme.smallSpace),
        Text(
          furtherInhibitors.join(', ')
        ),
      ];
    }
    return [
      SizedBox(height: PharMeTheme.smallSpace),
      Text(context.l10n.gene_page_inhibitor_drugs),
      SizedBox(height: PharMeTheme.smallSpace),
      Text(
        inhibitorsFor(gene).join(', ')
      ),
    ];
  }
}
