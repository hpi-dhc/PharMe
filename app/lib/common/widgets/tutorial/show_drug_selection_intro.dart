import 'dart:async';

import '../../module.dart';
import 'content.dart';
import 'controller.dart';

FutureOr<void> showDrugSelectionIntro(BuildContext context) =>
  TutorialController.instance.showTutorial(
    context: context,
    pages: [
      TutorialContent(
        title: (context) =>
          context.l10n.tutorial_initial_drug_selection_title,
        content: (context) => TextSpan(
          text: context.l10n.tutorial_initial_drug_selection_body,
        ),
      ),
    ],
    onClose: () async {
      MetaData.instance.initialDrugSelectionInitiated = true;
      await MetaData.save();
    }
  );