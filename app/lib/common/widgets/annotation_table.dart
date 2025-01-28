import '../../drug/widgets/tooltip_icon.dart';
import '../module.dart';

class TableRowDefinition {
  const TableRowDefinition(
    this.key,
    this.value,
    {
      this.keyTooltip,
      this.valueTooltip,
      this.italicValue = false,
    }
  );

  final String key;
  final String value;
  final String? keyTooltip;
  final String? valueTooltip;
  final bool italicValue;
}

Widget buildTable(
  List<TableRowDefinition> rowDefinitions,
  {
    TextStyle? style,
    bool boldKey = true,
  }
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: rowDefinitions.mapIndexed(
      (index, rowDefinition) => Table(
        defaultColumnWidth: IntrinsicColumnWidth(),
        children: [
          _buildRow(
            rowDefinition,
            style ?? PharMeTheme.textTheme.bodyMedium!,
            boldKey: boldKey,
            isLast: index == rowDefinitions.length - 1,
          ),
        ],
      ),
    ).toList(),
  );
}

TableRow _buildRow(
  TableRowDefinition rowDefinition,
  TextStyle textStyle,
  {
    required bool boldKey,
    required bool isLast,
  }
) {
  return TableRow(
    children: [
      Padding(
        padding: EdgeInsets.only(
          right: PharMeTheme.smallSpace,
          bottom: isLast ? 0 : PharMeTheme.smallSpace,
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: rowDefinition.key),
              ..._maybeBuildTooltip(rowDefinition.keyTooltip),
            ],
            style: boldKey
              ? textStyle.copyWith(fontWeight: FontWeight.bold)
              : textStyle,
          ),
        ),
      ),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: rowDefinition.value,
              style: rowDefinition.italicValue
                ? textStyle.copyWith(fontStyle: FontStyle.italic)
                : textStyle,
            ),
            ..._maybeBuildTooltip(rowDefinition.valueTooltip),
          ],
          style: textStyle,
        ),
      ),
    ],
  );
}

List<WidgetSpan> _maybeBuildTooltip(String? tooltip) {
  const tooltipSize = 16.0;
  return tooltip.isNotNullOrBlank
    ? [
        WidgetSpan(child: SizedBox(width: PharMeTheme.smallSpace)),
        WidgetSpan(
          child: TooltipIcon(tooltip!, size: tooltipSize),
        ),
        WidgetSpan(child: SizedBox(height: tooltipSize)),
      ]
    : [];
}

bool testResultIsUnknown(BuildContext context, String phenotype) =>
  unknownPhenotypes(context).contains(phenotype);

TableRowDefinition testResultTableRow(
  BuildContext context,
  {
    required GenotypeResult genotypeResult, 
    required String key,
    required String value,
    String? keyTooltip,
  }
) => TableRowDefinition(
  key,
  value,
  keyTooltip: keyTooltip,
  valueTooltip: value == indeterminateResult
    ? context.l10n.indeterminate_result_tooltip(
        genotypeResult.geneDisplayString,
      )
    : null,
  italicValue: testResultIsUnknown(context, value),
);

TableRowDefinition phenotypeTableRow(
  BuildContext context,
  {
    required String key,
    required GenotypeResult genotypeResult,
    required String? drug,
    String? keyTooltip,
  }
) {
  final value = possiblyAdaptedPhenotype(context, genotypeResult, drug: drug);
  return testResultTableRow(
    context,
    genotypeResult: genotypeResult,
    key: key,
    value: value,
    keyTooltip: keyTooltip,
  );
}