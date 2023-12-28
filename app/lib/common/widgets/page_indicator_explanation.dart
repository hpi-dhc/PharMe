import '../module.dart';

class PageIndicatorExplanation extends StatelessWidget {
  const PageIndicatorExplanation(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(PharMeTheme.smallSpace),
      child: Text(text),
    );
  }
}