import 'dart:async';

import 'package:flutter_markdown/flutter_markdown.dart';

import '../../module.dart';
import 'tutorial_controller.dart';
import 'tutorial_page.dart';

Widget _getTutorialContent(String text) => MarkdownBody(
  data: text,
  styleSheet: MarkdownStyleSheet.fromTheme(
    ThemeData(
      textTheme: TextTheme(
        bodyMedium: PharMeTheme.textTheme.bodyLarge,
      )
    )
  ),
);

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
          content: (context) => _getTutorialContent(
            context.l10n.tutorial_app_tour_1_body,
          ),
          assetPath:
            'assets/images/tutorial/05_bottom_navigation_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_2_title,
          content: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getTutorialContent(
                context.l10n.tutorial_app_tour_2_body_before_disclaimer,
              ),
              Padding(
                padding: EdgeInsets.all(PharMeTheme.smallSpace),
                child: ListInclusionDescription.forMedications(),
              ),
              _getTutorialContent(
                context.l10n.tutorial_app_tour_2_body_after_disclaimer,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: PharMeTheme.smallSpace),
                child: Text.rich(
                  buildWarningLevelTextLegend(context),
                ),
              ),
              _getTutorialContent(
                context.l10n.tutorial_app_tour_2_body_after_legend,
              ),
            ],
          ),
          assetPath:
            'assets/images/tutorial/06_drug_search_and_filter_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_3_title,
          content: (context) => _getTutorialContent(
            context.l10n.tutorial_app_tour_3_body,
          ),
          assetPath:
            'assets/images/tutorial/07_ibuprofen_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_4_title,
          content: (context) => _getTutorialContent(
            context.l10n.tutorial_app_tour_4_body,
          ),
          assetPath:
            'assets/images/tutorial/08_report_and_cyp2c9_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_5_title,
          content: (context) => _getTutorialContent(
            context.l10n.tutorial_app_tour_5_body,
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
            // ignore: use_build_context_synchronously
            await overwriteRoutes(context, nextPage: MainRoute());
          },
      lastNextButtonText: lastNextButtonText,
      firstBackButtonText: revisiting ? null : context.l10n.onboarding_prev,
    );