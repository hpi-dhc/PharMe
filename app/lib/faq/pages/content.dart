import '../../common/module.dart';

typedef FaqQuestionBuilder = FaqQuestion Function(BuildContext context);

class FaqSection {
  FaqSection({required this.title, required this.questions});

  final String Function(BuildContext context) title;
  final List<FaqQuestionBuilder> questions;
}

abstract class FaqQuestion {
  const FaqQuestion({
    required this.question,
    required this.answer,
  });

  final String question;
  final dynamic answer;
}

class FaqTextAnswerQuestion extends FaqQuestion {
  const FaqTextAnswerQuestion({
    required super.question,
    required String super.answer,
  });
}

class FaqWidgetAnswerQuestion extends FaqQuestion {
  const FaqWidgetAnswerQuestion({
    required super.question,
    required Widget super.answer,
  });
}

Column _getPhenoconversionString(
  Map<String, Map<String, dynamic>> modulators,
  String Function(String) getDescriptionPerGene,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ...modulators.keys.flatMap(
      (geneName) => [
        Text(
          getDescriptionPerGene(geneName),
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        SizedBox(height: PharMeTheme.smallSpace * 0.5),
        UnorderedList(
          getDrugsWithBrandNames(
            modulators[geneName]!.keys.toList(),
            capitalize: true,
          ),
        ),
      ]),
    ],
  );
}

final faqContent = <FaqSection>[
  FaqSection(
    title: (context) => context.l10n.faq_section_title_pgx,
    questions: [
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_pgx_what,
        answer: context.l10n.faq_answer_pgx_what,
      ),
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_pgx_why,
        answer: context.l10n.faq_answer_pgx_why,
      ),
      (context) => FaqWidgetAnswerQuestion(
        question: context.l10n.faq_question_genetics_info,
        answer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.faq_answer_genetics_info),
            SizedBox(height: PharMeTheme.smallSpace * 0.5),
            Hyperlink(
              text: geneticInformationUrl.toString(),
              onTap: openFurtherGeneticInformation,
            ),
          ],
        ),
      ),
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_which_medications,
        answer: context.l10n.faq_answer_which_medications,
      ),
      (context) => FaqWidgetAnswerQuestion(
        question: context.l10n.faq_question_phenoconversion,
        answer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.faq_answer_phenoconversion),
            SizedBox(height: PharMeTheme.smallSpace * 0.5),
            _getPhenoconversionString(
              strongDrugInhibitors,
              context.l10n.faq_strong_inhibitors,
            ),
            SizedBox(height: PharMeTheme.smallSpace * 0.5),
            _getPhenoconversionString(
              moderateDrugInhibitors,
              context.l10n.faq_moderate_inhibitors,
            ),
          ],
        ),
      ),
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_family,
        answer: context.l10n.faq_answer_family,
      ),
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_share,
        answer: context.l10n.faq_answer_share,
      ),
    ],
  ),
  FaqSection(
    title: (context) => context.l10n.faq_section_title_pharme,
    questions: [
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_pharme_function,
        answer: context.l10n.faq_answer_pharme_function,
      ),
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_pharme_hcp,
        answer: context.l10n.faq_answer_pharme_hcp,
      ),
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_pharme_data_source,
        answer: context.l10n.faq_answer_pharme_data_source,
      ),
    ],
  ),
  FaqSection(
    title: (context) => context.l10n.faq_section_title_security,
    questions: [
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_data_security,
        answer: context.l10n.faq_answer_data_security,
      ),
    ],
  ),
];
