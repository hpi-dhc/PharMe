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
        content: (context) => TextSpan(
          text: context.l10n.tutorial_initial_drug_selection_body,
        ),
      ),
    ],
    onClose: () async {
      MetaData.instance.initialDrugSelectionInitiated = true;
      await MetaData.save();
    },
    firstBackButtonText: context.l10n.onboarding_prev,
  );