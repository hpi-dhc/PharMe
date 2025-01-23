import '../../drug/widgets/tooltip_icon.dart';
import '../module.dart';

class TableRowDefinition {
  const TableRowDefinition(
    this.key,
    this.value,
    {
      this.keyTooltip,
      this.valueTooltip,
    }
  );

  final String key;
  final String value;
  final String? keyTooltip;
  final String? valueTooltip;
}

Widget buildTable(
  List<TableRowDefinition> rowDefinitions,
  {
    TextStyle? style,
    bool boldKey = true,
    bool italicValue = false,
  }
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: rowDefinitions.mapIndexed(
      (index, rowDefinition) => Table(
        defaultColumnWidth: IntrinsicColumnWidth(),
        children: [
          _buildRow(
            rowDefinition.key,
            rowDefinition.value,
            style ?? PharMeTheme.textTheme.bodyMedium!,
            boldKey: boldKey,
            isLast: index == rowDefinitions.length - 1,
            keyTooltip: rowDefinition.keyTooltip,
            valueTooltip: rowDefinition.valueTooltip,
          ),
        ],
      ),
    ).toList(),
  );
}

TableRow _buildRow(
  String key,
  String value,
  TextStyle textStyle,
  {
    required bool boldKey,
    required bool isLast,
    String? keyTooltip,
    String? valueTooltip,
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
              TextSpan(text: key),
              ..._maybeBuildTooltip(keyTooltip),
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
            TextSpan(text: value),
            ..._maybeBuildTooltip(valueTooltip),
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