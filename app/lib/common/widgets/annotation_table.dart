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
              TextSpan(text: ' '),
              WidgetSpan(
                child: TooltipIcon(tooltip!),
              ),
            ],
          ],
          style: textStyle,
        ),
      ),
    ],
  );
}