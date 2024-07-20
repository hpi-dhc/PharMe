import '../../../common/module.dart';

class Disclaimer extends StatelessWidget {
  const Disclaimer({ this.userGuideline });

  final Guideline? userGuideline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(PharMeTheme.smallSpace),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(PharMeTheme.innerCardRadius * 0.75)
        ),
        color: PharMeTheme.surfaceColor,
        border: Border.all(color: PharMeTheme.errorColor, width: 1.2),
      ),
      child: Text.rich(
        TextSpan(children: [
          WidgetSpan(
            child: Icon(
              Icons.warning_rounded,
              size: PharMeTheme.mediumSpace,
              color: PharMeTheme.errorColor,
            ),
          ),
          TextSpan(text: ' '),
          TextSpan(
            text: context.l10n.drugs_page_disclaimer_description,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: context.l10n.drugs_page_disclaimer_text_part_0,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          if (userGuideline != null) TextSpan(
            children: [
              TextSpan(text: '\n\n'),
              TextSpan(text: context.l10n.drugs_page_disclaimer_text_part_1),
              TextSpan(text: ' '),
              TextSpan(text: context.l10n.drugs_page_disclaimer_text_part_2),
            ],
            style: PharMeTheme.textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.w300,
            ),
          )
        ]),
      ),
    );
  }
}
