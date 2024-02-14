import '../module.dart';

class PageDescription extends StatelessWidget {
  const PageDescription(this.widget);

  factory PageDescription.fromText(String text) =>
    PageDescription(PageDescriptionText(text));

  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: PharMeTheme.smallSpace,
        right: PharMeTheme.smallSpace,
        bottom: PharMeTheme.smallSpace),
      child: widget,
    );
  }
}

final pageDescriptionTextStyle = PharMeTheme.textTheme.bodyMedium;

class PageDescriptionText extends StatelessWidget {
  const PageDescriptionText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: pageDescriptionTextStyle);
  }
}