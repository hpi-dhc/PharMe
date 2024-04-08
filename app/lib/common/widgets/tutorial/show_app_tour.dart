import 'dart:async';

import '../../module.dart';
import 'content.dart';
import 'controller.dart';

FutureOr<void> showAppTour(
  BuildContext context,
  {
    required String lastNextButtonText,
    required bool revisiting,
  }) =>
    TutorialController.instance.showTutorial(
      context: context,
      pages: [
        TutorialContent(
          title: (context) =>
            context.l10n.tutorial_app_tour_1_title,
          content: (context) => TextSpan(
            text: context.l10n.tutorial_app_tour_1_body,
          ),
          assetPath:
            'assets/images/tutorial/04_bottom_navigation_loopable.gif',
        ),
      ],
      onClose: revisiting
        ? null
        : () async {
          MetaData.instance.tutorialDone = true;
          await MetaData.save();
        },
      lastNextButtonText: lastNextButtonText,
    );