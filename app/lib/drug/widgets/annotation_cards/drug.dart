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
                      context.l10n.drugs_page_header_synonyms,
                      drug.annotations.brandNames.join(', '),
                    ),
                ]),
                if (isInhibitor(drug.name)) ...[
                  SizedBox(height: 8),
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
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: PharMeTheme.mediumSpace),
        SubHeader(context.l10n.drugs_page_header_active),
        SizedBox(height: PharMeTheme.smallSpace),
        RoundedCard(
          innerPadding: EdgeInsets.all(PharMeTheme.smallSpace),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: PharMeTheme.smallSpace),
            child: DropdownButton<bool>(
              key: Key('drug-status-selection-${drug.name}'),
              value: isActive,
              isExpanded: true,
              icon: const Icon(Icons.expand_more),
              onChanged: disabled ? null : (newValue) => {
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
                          onPressed: () => Navigator.pop(context, 'Cancel'),
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
                  )
                } else {
                  setActivity(value: newValue)
                }
              },
              items: [
                DropdownMenuItem<bool>(
                  key: Key('drug-status-selection-${drug.name}-active'),
                  value: true,
                  child: _buildStatusMenuItem(
                    context.l10n.drugs_page_active,
                    Icons.check_circle_outline,
                  ),
                ),
                DropdownMenuItem<bool>(
                  key: Key('drug-status-selection-${drug.name}-inactive'),
                  value: false,
                  child: _buildStatusMenuItem(
                    context.l10n.drugs_page_inactive,
                    Icons.cancel_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMenuItem(String text, IconData iconData) => Text.rich(
    TextSpan(
      children: [
        WidgetSpan(
          child: Icon(
            iconData,
            color: PharMeTheme.iconColor,
          ),
        ),
        TextSpan(text: ' $text'),
      ],
    ),
    maxLines: 1,
    softWrap: false,
    overflow: TextOverflow.fade,
  );
}
