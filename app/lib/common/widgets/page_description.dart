import '../module.dart';

class PageDescription extends StatelessWidget {
  const PageDescription(this.widget);

  factory PageDescription.fromText(String text) =>
    PageDescription(Text(text));

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
