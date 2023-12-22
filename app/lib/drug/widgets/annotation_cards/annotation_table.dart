import '../../../common/module.dart';

class TableRowDefinition {
  const TableRowDefinition(this.key, this.value);
  final String key;
  final String value;
}

Table buildTable(
  List<TableRowDefinition> rowDefinitions,
  {
    TextStyle? style,
  }
) {
  return Table(
    defaultColumnWidth: IntrinsicColumnWidth(),
    children: rowDefinitions.map((rowDefinition) => _buildRow(
      rowDefinition.key,
      rowDefinition.value,
      style ?? PharMeTheme.textTheme.bodyMedium!,
    )).toList(),
  );
}

TableRow _buildRow(
  String key,
  String value,
  TextStyle textStyle,
) {
  return TableRow(
    children: [
      Padding(
        padding: EdgeInsets.only(right: PharMeTheme.smallSpace),
        child: Text(
          key,
          style: textStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      Text(value, style: textStyle),
    ],
  );
}