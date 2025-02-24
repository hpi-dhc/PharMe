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

List<FaqSection> getFaqContent() => <FaqSection>[
  FaqSection(
    title: (context) => context.l10n.faq_section_title_pharme,
    questions: [
      (context) => FaqWidgetAnswerQuestion(
        question: context.l10n.faq_question_pharme_function,
        answer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.faq_answer_pharme_function),
            SizedBox(height: PharMeTheme.smallSpace),
            PuzzleDisclaimerCard(elevation: 0),
            SizedBox(height: PharMeTheme.smallSpace * 0.5),
            IncludedMedicationsDisclaimerCard(elevation: 0),
          ],
        ),
      ),
      (context) => FaqWidgetAnswerQuestion(
        question: context.l10n.faq_question_pharme_hcp,
        answer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.faq_answer_pharme_hcp),
            SizedBox(height: PharMeTheme.smallSpace),
            ProfessionalDisclaimerCard(elevation: 0),
          ],
        ),
      ),
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_pharme_data_source,
        answer: context.l10n.faq_answer_pharme_data_source,
      ),
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_data_security,
        answer: context.l10n.faq_answer_data_security,
      ),
    ],
  ),
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
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_adr_factors,
        answer: context.l10n.faq_answer_adr_factors,
      ),
      (context) => FaqTextAnswerQuestion(
        question: context.l10n.faq_question_guidelines_are_developing,
        answer: context.l10n.faq_answer_guidelines_are_developing,
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
            SizedBox(height: PharMeTheme.smallSpace * 0.5),
            Text('\n${context.l10n.consult_text}'),
          ],
        ),
      ),
      (context) => FaqWidgetAnswerQuestion(
        question: context.l10n.faq_question_which_medications,
        answer: Column(
          children: [
            Text(context.l10n.faq_answer_which_medications),
            SizedBox(height: PharMeTheme.smallSpace * 0.5),
            UnorderedList(
              context.l10n.faq_answer_which_medications_examples
                .split('; ')
                .map((example) => example.capitalize()).toList(),
            ),
          ],
        ),
      ),
      (context) => FaqWidgetAnswerQuestion(
        question: context.l10n.faq_question_phenoconversion,
        answer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.faq_answer_phenoconversion),
            SizedBox(height: PharMeTheme.smallSpace),
            ...inhibitableGenes.map(
              (geneName) => GeneModulatorList(geneName: geneName).widget,
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
];
