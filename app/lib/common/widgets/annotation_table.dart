import '../../drug/widgets/tooltip_icon.dart';
import '../module.dart';

class TableRowDefinition {
  const TableRowDefinition(this.key, this.value, { this.tooltip });
  final String key;
  final String value;
  final String? tooltip;
}

Table buildTable(
  List<TableRowDefinition> rowDefinitions,
  {
    TextStyle? style,
    bool boldHeader = true,
  }
) {
  return Table(
    defaultColumnWidth: IntrinsicColumnWidth(),
    children: rowDefinitions.mapIndexed((index, rowDefinition) => _buildRow(
      rowDefinition.key,
      rowDefinition.value,
      style ?? PharMeTheme.textTheme.bodyMedium!,
      boldHeader: boldHeader,
      isLast: index == rowDefinitions.length - 1,
      tooltip: rowDefinition.tooltip,
    )).toList(),
  );
}

TableRow _buildRow(
  String key,
  String value,
  TextStyle textStyle,
  {
    required bool boldHeader,
    required bool isLast,
    String? tooltip,
  }
) {
  const tooltipSize = 16.0;

  return TableRow(
    children: [
      Padding(
        padding: EdgeInsets.only(
          right: PharMeTheme.smallSpace,
          bottom: isLast ? 0 : PharMeTheme.smallSpace,
        ),
        child: Text(
          key,
          style: boldHeader
            ? textStyle.copyWith(fontWeight: FontWeight.bold)
            : textStyle,
        ),
      ),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(text: value),
            if (tooltip.isNotNullOrBlank) ...[
              WidgetSpan(child: SizedBox(width: PharMeTheme.smallSpace)),
              WidgetSpan(
                child: TooltipIcon(tooltip!, size: tooltipSize),
              ),
            ],
            WidgetSpan(child: SizedBox(height: tooltipSize)),
          ],
          style: textStyle,
        ),
      ),
    ],
  );
}