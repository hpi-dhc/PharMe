import '../module.dart';

class TableRowDefinition {
  const TableRowDefinition(this.key, this.value);
  final String key;
  final String value;
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
      Text(value, style: textStyle),
    ],
  );
}