import '../module.dart';

class PageIndicatorExplanation extends StatelessWidget {
  const PageIndicatorExplanation(this.text, {this.indicator});

  final String? indicator;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textStyle = PharMeTheme.textTheme.labelMedium!.copyWith(
      fontStyle: FontStyle.italic,
    );
    return Padding(
      padding: EdgeInsets.all(PharMeTheme.smallSpace),
      child: indicator.isNotNullOrBlank
      ? buildTable(
          [TableRowDefinition(indicator!, text)],
          boldHeader: false,
          style: textStyle,
        )
      : Text(text, style: textStyle),
    );
  }
}