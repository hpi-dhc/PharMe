import 'package:flutter/material.dart';

import '../../../l10n.dart';
import '../../../theme.dart';

class Disclaimer extends StatelessWidget {
  const Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: PharMeTheme.surfaceColor,
        border: Border.all(color: PharMeTheme.errorColor, width: 1.2),
      ),
      child: Row(children: [
        Icon(
          Icons.warning_rounded,
          size: 52,
          color: PharMeTheme.errorColor,
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            context.l10n.medications_page_disclaimer,
            style: PharMeTheme.textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
      ]),
    );
  }
}
