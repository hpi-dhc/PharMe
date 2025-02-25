import 'dart:async';

import '../../module.dart';
import 'tutorial_controller.dart';
import 'tutorial_page.dart';

FutureOr<void> showDrugSelectionIntro(BuildContext context) =>
  TutorialController.instance.showTutorial(
    context: context,
    pages: [
      TutorialPage(
        title: (context) =>
          context.l10n.tutorial_initial_drug_selection_title,
        content: (context) => Text(
          context.l10n.tutorial_initial_drug_selection_body,
          style: TextStyle(fontSize: PharMeTheme.textTheme.bodyLarge?.fontSize),
        ),
      ),
    ],
    onClose: () async {
      MetaData.instance.initialDrugSelectionInitiated = true;
      await MetaData.save();
    },
    firstBackButtonText: context.l10n.onboarding_prev,
    fitToContent: true,
  );