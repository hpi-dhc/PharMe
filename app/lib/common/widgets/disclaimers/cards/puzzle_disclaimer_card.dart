import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../module.dart';

class PuzzleDisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DisclaimerCard(
    icon: FontAwesomeIcons.puzzlePiece,
    iconPadding: EdgeInsets.all(PharMeTheme.smallSpace * 0.4),
    text: context.l10n.drugs_page_puzzle_disclaimer_text,
  );
}