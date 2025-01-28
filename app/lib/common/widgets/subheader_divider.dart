import '../module.dart';

TextStyle subheaderDividerStyle({Color? color}) =>
  PharMeTheme.textTheme.bodySmall!.copyWith(
    color: color ?? PharMeTheme.subheaderColor,
  );

class SubheaderDivider extends StatelessWidget {
  const SubheaderDivider({
    this.text = '',
    this.padding,
    this.color,
    this.useLine = true,
    super.key,
  });

  final String text;
  final double? padding;
  final Color? color;
  final bool useLine;

  @override
  Widget build(BuildContext context) {
    final widgetColor = color ?? PharMeTheme.subheaderColor;
    return Padding(
      padding: EdgeInsets.all(padding ?? PharMeTheme.smallSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (useLine) Divider(color: widgetColor, thickness: 0.5),
          Text(
            text,
            style: subheaderDividerStyle(color: widgetColor),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}