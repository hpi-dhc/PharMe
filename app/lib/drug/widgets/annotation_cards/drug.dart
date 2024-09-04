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
  final void Function({ bool? value }) setActivity;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RoundedCard(
          innerPadding: EdgeInsets.symmetric(horizontal: PharMeTheme.mediumSpace),
          child: Column(
            children: [
              SwitchListTile.adaptive(
                value: isActive,
                activeColor: PharMeTheme.primaryColor,
                title: Text(context.l10n.drugs_page_text_active),
                contentPadding: EdgeInsets.zero,
                onChanged: disabled ? null : (newValue) {
                  if (isInhibitor(drug.name)) {
                    showAdaptiveDialog(
                      context: context,
                      builder: (context) => DialogWrapper(
                        title: context.l10n.drugs_page_active_warn_header,
                        content: DialogContentText(
                          context.l10n.drugs_page_active_warn,
                        ),
                        actions: [
                          DialogAction(
                            onPressed: () => Navigator.pop(
                              context,
                              'Cancel',
                            ),
                            text: context.l10n.action_cancel,
                          ),
                          DialogAction(
                            onPressed: () {
                              Navigator.pop(context, 'OK');
                              setActivity(value: newValue);
                            },
                            text: context.l10n.action_continue,
                            isDestructive: true,
                          ),
                        ],
                      ),
                    );
                  } else {
                    setActivity(value: newValue);
                  }
                },
              ),
              if (isInhibitor(drug.name)) ...[
                SizedBox(height: PharMeTheme.smallSpace),
                buildTable(
                  [TableRowDefinition(
                    drugInteractionIndicator,
                    context.l10n.drugs_page_is_inhibitor(
                      drug.name,
                      inhibitedGenes(drug).join(', '),
                    ),
                  )],
                  boldHeader: false,
                ),
                SizedBox(height: PharMeTheme.smallSpace),
              ],
            ],
          )
        ),
        SizedBox(height: PharMeTheme.smallSpace),
        SubHeader(context.l10n.drugs_page_header_drug),
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
                  if (drug.annotations.brandNames.isNotEmpty)
                    TableRowDefinition(
                      context.l10n.drug_item_brand_names,
                      drug.annotations.brandNames.join(', '),
                    ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
