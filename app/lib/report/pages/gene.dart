import '../../common/module.dart';
import '../../common/pages/drug/widgets/sub_header.dart';
import '../../common/pages/drug/widgets/tooltip_icon.dart';

class GenePage extends StatelessWidget {
  const GenePage(this.phenotype);
  final CpicPhenotype phenotype;

  @override
  Widget build(BuildContext context) {
    return pageScaffold(
        title: context.l10n.gene_page_headline(phenotype.geneSymbol),
        body: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SubHeader(
                context.l10n.gene_page_your_variant(phenotype.geneSymbol),
                tooltip:
                    context.l10n.gene_page_name_tooltip(phenotype.geneSymbol),
              ),
              SizedBox(height: 12),
              RoundedCard(
                child: Table(
                    columnWidths: Map.from({
                      0: IntrinsicColumnWidth(),
                      1: IntrinsicColumnWidth(flex: 1),
                    }),
                    children: [
                      _buildRow(
                          context.l10n.gene_page_genotype, phenotype.genotype,
                          tooltip: context.l10n.gene_page_genotype_tooltip),
                      _buildRow(context.l10n.gene_page_phenotype,
                          UserData.phenotypeFor(phenotype.geneSymbol)!,
                          tooltip: context.l10n.gene_page_phenotype_tooltip),
                    ]),
              ),
            ]),
          ),
        ]);
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