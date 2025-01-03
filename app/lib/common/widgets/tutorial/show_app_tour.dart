import 'dart:async';

import '../../module.dart';
import 'tutorial_controller.dart';
import 'tutorial_page.dart';

TextSpan _buildContent(String text, { InlineSpan? trailingSpan }) {
  final paragraphs = text.split('\n');
  final spacerSpan = WidgetSpan(child: SizedBox(height: 25));
  var spacedParagraphs = <InlineSpan>[];
  for (final (index, paragraph) in paragraphs.indexed) {
    final isLast = index == paragraphs.length - 1;
    final paragraphSpan = isLast
      ? TextSpan(text: paragraph)
      : TextSpan(text: '$paragraph\n');
    spacedParagraphs = isLast
      ? [...spacedParagraphs, paragraphSpan]
      : [...spacedParagraphs, paragraphSpan, spacerSpan];
  }
  if (trailingSpan != null) {
    spacedParagraphs = [...spacedParagraphs, TextSpan(text: '\n'), spacerSpan, trailingSpan];
  }
  return TextSpan(children: spacedParagraphs);
}

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
          content: (context) => _buildContent(
            context.l10n.tutorial_app_tour_1_body,
          ),
          assetPath:
            'assets/images/tutorial/05_bottom_navigation_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_2_title,
          content: (context) => TextSpan(
            children: [
              _buildContent(
                context.l10n.tutorial_app_tour_2_body,
                trailingSpan: buildWarningLevelTextLegend(context),
              ),
            ],
          ),
          assetPath:
            'assets/images/tutorial/06_drug_search_and_filter_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_3_title,
          content: (context) => _buildContent(
            context.l10n.tutorial_app_tour_3_body,
          ),
          assetPath:
            'assets/images/tutorial/07_ibuprofen_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_4_title,
          content: (context) => _buildContent(
            context.l10n.tutorial_app_tour_4_body,
          ),
          assetPath:
            'assets/images/tutorial/08_report_and_cyp2c9_loopable.gif',
        ),
        TutorialPage(
          title: (context) =>
            context.l10n.tutorial_app_tour_5_title,
          content: (context) => _buildContent(
            context.l10n.tutorial_app_tour_5_body,
            trailingSpan: TextSpan(
              text: context.l10n.tutorial_app_tour_5_body_bold,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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