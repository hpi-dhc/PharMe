import '../../../common/module.dart';
import '../sub_header.dart';

class DrugAnnotationCards extends StatelessWidget {
  const DrugAnnotationCards(
    this.drug, {
    required this.isActive,
    required this.setActivity,
    this.disabled = false,
  });

  final Drug drug;
  final bool isActive;
  final SetDrugActivityFunction setActivity;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RoundedCard(
          innerPadding: EdgeInsets.symmetric(
            horizontal: PharMeTheme.mediumSpace,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (drug.annotations.brandNames.isNotEmpty) ...[
                SizedBox(height: PharMeTheme.mediumSpace),
                buildTable([
                  TableRowDefinition(
                    context.l10n.drug_item_brand_names,
                    drug.annotations.brandNames.join(', '),
                  ),
                ]),
              ],
              buildDrugActivitySelection(
                context: context,
                drug: drug,
                setActivity: setActivity,
                title: context.l10n.drugs_page_text_active,
                titleStyle: PharMeTheme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                isActive: isActive,
                disabled: disabled,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        SizedBox(height: PharMeTheme.smallSpace),
        PrettyExpansionTile(
          key: Key('drug-information-expansion-tile'),
          title: SubHeader(context.l10n.drugs_page_header_drug),
          visualDensity: VisualDensity.compact,
          titlePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          children: [
            SizedBox(height: PharMeTheme.smallSpace),
            RoundedCard(
              innerPadding: EdgeInsets.all(PharMeTheme.mediumSpace),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(drug.annotations.indication),
                    SizedBox(height: PharMeTheme.smallSpace),
                    buildTable([
                      TableRowDefinition(
                        context.l10n.drugs_page_header_drugclass,
                        drug.annotations.drugclass,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
