import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../common/module.dart';

class GuidelineDisclaimer extends StatelessWidget {
  const GuidelineDisclaimer({ this.userGuideline });

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
      child: Column(
        children: [
          DisclaimerRow(
            icon: Icon(
              Icons.warning_rounded,
              size: PharMeTheme.mediumSpace,
              color: PharMeTheme.errorColor,
            ),
            text: Text(
              context.l10n.drugs_page_main_disclaimer_text,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: PharMeTheme.smallSpace),
          DisclaimerRow(
            icon: IncludedContentIcon(
              type: ListInclusionDescriptionType.genes,
              size: PharMeTheme.mediumSpace,
              color: PharMeTheme.onSurfaceText,
            ),
            text: Text(ListInclusionDescriptionType.genes.getText(context)),
          ),
          SizedBox(height: PharMeTheme.smallSpace),
          DisclaimerRow(
            icon: Icon(
              FontAwesomeIcons.puzzlePiece,
              size: PharMeTheme.mediumSpace,
              color: PharMeTheme.onSurfaceText,
            ),
            text: Text(context.l10n.drugs_page_puzzle_disclaimer_text),
          ),
        ],
      ),
    );
  }
}
