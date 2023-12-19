import '../module.dart';

class SubheaderDivider extends StatelessWidget {
  const SubheaderDivider(
    this.text, {
    this.indent = 20.0,
    this.color,
    super.key,
  });

  final String text;
  final double indent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final widgetColor = color ?? Colors.grey[600];
    return Padding(
      padding: EdgeInsets.all(PharMeTheme.smallSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: widgetColor),
          Text(
            text,
            style:
              PharMeTheme.textTheme.bodySmall!.copyWith(color: widgetColor),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}