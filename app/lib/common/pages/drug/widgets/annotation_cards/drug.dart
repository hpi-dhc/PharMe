import '../../../../module.dart';

class DrugAnnotationCard extends StatelessWidget {
  const DrugAnnotationCard(this.drug);

  final Drug drug;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
