import '../module.dart';

class PageDescription extends StatelessWidget {
  const PageDescription(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: PharMeTheme.smallSpace,
        right: PharMeTheme.smallSpace,
        bottom: PharMeTheme.smallSpace),
      child: Text(text, style: PharMeTheme.textTheme.bodyMedium),
    );
  }
}