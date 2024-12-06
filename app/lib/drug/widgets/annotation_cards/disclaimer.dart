import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            text: context.l10n.drugs_page_main_disclaimer_text,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            children: [
              TextSpan(text: '\n\n'),
              WidgetSpan(
                child: Icon(
                  FontAwesomeIcons.puzzlePiece,
                  size: PharMeTheme.mediumSpace,
                  color: PharMeTheme.onSurfaceText,
                ),
              ),
              TextSpan(text: ' '),
              TextSpan(text: context.l10n.drugs_page_puzzle_disclaimer_text),
            ],
          )
        ]),
      ),
    );
  }
}
