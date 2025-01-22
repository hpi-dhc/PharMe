import '../module.dart';

TextSpan boldListDescriptionText(String text, { Color? color }) => TextSpan(
  text: text,
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: color ?? PharMeTheme.iconColor,
  ),
);

class ListDescription extends StatelessWidget {
  const ListDescription({
    super.key,
    required this.textParts,
    required this.detailsText,
  });

  final List<TextSpan> textParts;
  final String detailsText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: PharMeTheme.mediumSpace,
        horizontal: PharMeTheme.smallSpace,
      ),
      child: Text.rich(
        style: subheaderDividerStyle(color: PharMeTheme.onSurfaceText),
        TextSpan(
          children: [
            ...textParts,
            TextSpan(text: ' '),
            TextSpan(text: context.l10n.list_subheader_postfix),
            TextSpan(text: ' '),
            TextSpan(
              text: '($detailsText)',
              style: TextStyle(color: PharMeTheme.buttonColor),
            ),
          ],
        ),
      ),
    );
  }
  
}