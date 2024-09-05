import '../module.dart';

// Based on https://stackoverflow.com/a/62341566

class UnorderedList extends StatelessWidget {
  const UnorderedList(this.texts);
  final List<String> texts;

  @override
  Widget build(BuildContext context) {
    final widgetList = <Widget>[];
    for (final text in texts) {
      widgetList.add(UnorderedListItem(text));
      widgetList.add(SizedBox(height: 5));
    }
    return Column(children: widgetList);
  }
}

class UnorderedListItem extends StatelessWidget {
  const UnorderedListItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('• '),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}
