import '../../../common/module.dart';

class Disclaimer extends StatelessWidget {
  const Disclaimer({this.text});

  final String? text;

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
      child: Row(children: [
        Icon(
          Icons.warning_rounded,
          size: PharMeTheme.largeSpace,
          color: PharMeTheme.errorColor,
        ),
        SizedBox(width: PharMeTheme.smallSpace),
        Flexible(
          child: Text(
            text ?? context.l10n.drugs_page_disclaimer,
            style: PharMeTheme.textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ]),
    );
  }
}
