import '../module.dart';

class PageDescription extends StatelessWidget {
  const PageDescription(this.widget, { this.customPadding });

  factory PageDescription.fromText(String text) =>
    PageDescription(Text(text));

  final Widget widget;
  final EdgeInsets? customPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: customPadding ?? EdgeInsets.only(
        left: PharMeTheme.smallSpace,
        right: PharMeTheme.smallSpace,
        bottom: PharMeTheme.smallSpace),
      child: widget,
    );
  }
}
