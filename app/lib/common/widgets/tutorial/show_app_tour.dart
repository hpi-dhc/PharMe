import 'dart:async';

import '../../module.dart';
import 'tutorial_controller.dart';
import 'tutorial_page.dart';

FutureOr<void> showAppTour(
  BuildContext context,
  {
    required String lastNextButtonText,
    required bool revisiting,
  }) =>
    TutorialController.instance.showTutorial(
      context: context,
      pages: [
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_1_title,
          content: (context) => TextSpan(
            text: context.l10n.tutorial_app_tour_1_body,
          ),
          assetPath:
            'assets/images/tutorial/05_bottom_navigation_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_2_title,
          content: (context) => TextSpan(
            children: [
              TextSpan(text: context.l10n.tutorial_app_tour_2_body),
              WarningLevel.values.getTextLegend(context),
            ],
          ),
          assetPath:
            'assets/images/tutorial/06_drug_search_and_filter_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_3_title,
          content: (context) => TextSpan(
            text: context.l10n.tutorial_app_tour_3_body,
          ),
          assetPath:
            'assets/images/tutorial/07_clopidogrel_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_4_title,
          content: (context) => TextSpan(
            text: context.l10n.tutorial_app_tour_4_body,
          ),
          assetPath:
            'assets/images/tutorial/08_report_and_cyp2c19_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_5_title,
          content: (context) => TextSpan(
            text: context.l10n.tutorial_app_tour_5_body,
          ),
          assetPath:
            'assets/images/tutorial/09_faq_and_more_loopable.gif',
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