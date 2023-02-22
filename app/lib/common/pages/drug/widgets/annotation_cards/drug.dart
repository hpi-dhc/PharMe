import '../../../../module.dart';
import '../sub_header.dart';

class DrugAnnotationCard extends StatelessWidget {
  const DrugAnnotationCard(
    this.drug, {
    required this.isActive,
    required this.setActivity,
  });

  final Drug drug;
  final bool isActive;
  final void Function(bool?) setActivity;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubHeader(context.l10n.drugs_page_header_druginfo),
            SizedBox(height: 12),
            Text(drug.annotations.indication),
            SizedBox(height: 8),
            Table(defaultColumnWidth: IntrinsicColumnWidth(), children: [
              _buildRow(context.l10n.drugs_page_header_drugclass,
                  drug.annotations.drugclass),
              if (drug.annotations.brandNames.isNotEmpty) ...[
                _buildRow(context.l10n.drugs_page_header_synonyms,
                    drug.annotations.brandNames.join(', ')),
              ]
            ]),
            SizedBox(height: 12),
            SubHeader(context.l10n.drugs_page_header_active),
            CheckboxListTile(
              title: Text(context.l10n.drugs_page_active),
              value: isActive,
              onChanged: setActivity,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(String key, String value) => TableRow(children: [
        Padding(
            padding: EdgeInsets.fromLTRB(0, 4, 12, 4),
            child: Text(key,
                style: PharMeTheme.textTheme.bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.fromLTRB(0, 4, 0, 4), child: Text(value)),
      ]);
}
