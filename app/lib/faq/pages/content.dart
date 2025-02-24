import '../../common/module.dart';

typedef FaqQuestionBuilder = FaqQuestion Function(BuildContext context);

class FaqSection {
  FaqSection({required this.title, required this.questions});

  final String Function(BuildContext context) title;
  final List<FaqQuestionBuilder> questions;
}

class FaqQuestion {
  const FaqQuestion({
    required this.question,
    required this.answer,
    this.answerWidgets,
    this.widgetsBeforeText = false,
  });

  final String question;
  final String answer;
  final Iterable<Widget>? answerWidgets;
  final bool widgetsBeforeText;

  Widget get answerWidget {
    final textContent = LargeMarkdownBody(data: answer);
    if (answerWidgets == null) return textContent;
    final answerChildren = widgetsBeforeText
      ? [
          ...answerWidgets!,
          SizedBox(height: PharMeTheme.mediumSpace),
          textContent,
        ]
      : [
          textContent,
          SizedBox(height: PharMeTheme.smallSpace),
          ...answerWidgets!,
        ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: answerChildren,
    );
  }
}

List<FaqSection> getFaqContent() => <FaqSection>[
  FaqSection(
    title: (context) => context.l10n.faq_section_title_pharme,
    questions: [
      (context) => FaqQuestion(
        question: context.l10n.faq_question_pharme_function,
        answer: context.l10n.faq_answer_pharme_function,
        answerWidgets: [
          PuzzleDisclaimerCard(),
          IncludedContentDisclaimerCard(
            type: ListInclusionDescriptionType.medications,
          ),
        ],
      ),
      (context) => FaqQuestion(
        question: context.l10n.faq_question_pharme_hcp,
        answer: context.l10n.faq_answer_pharme_hcp,
        answerWidgets: [ProfessionalDisclaimerCard()],
      ),
      (context) => FaqQuestion(
        question: context.l10n.faq_question_pharme_data_source,
        answer: context.l10n.faq_answer_pharme_data_source,
      ),
      (context) => FaqQuestion(
        question: context.l10n.faq_question_data_security,
        answer: context.l10n.faq_answer_data_security,
      ),
    ],
  ),
  FaqSection(
    title: (context) => context.l10n.faq_section_title_pgx,
    questions: [
      (context) => FaqQuestion(
        question: context.l10n.faq_question_pgx_what,
        answer: context.l10n.faq_answer_pgx_what,
        answerWidgets: [PgxInfoCard()],
        widgetsBeforeText: true,
      ),
      (context) => FaqQuestion(
        question: context.l10n.faq_question_pgx_why,
        answer: context.l10n.faq_answer_pgx_why,
        answerWidgets: [PuzzleDisclaimerCard()],
      ),
      (context) => FaqQuestion(
        question: context.l10n.faq_question_adr_factors,
        answer: context.l10n.faq_answer_adr_factors,
      ),
      (context) => FaqQuestion(
        question: context.l10n.faq_question_guidelines_are_developing,
        answer: context.l10n.faq_answer_guidelines_are_developing,
        answerWidgets: [
          IncludedContentDisclaimerCard(
            type: ListInclusionDescriptionType.genes,
          ),
        ],
      ),
      (context) => FaqQuestion(
        question: context.l10n.faq_question_genetics_info,
        answer: context.l10n.faq_answer_genetics_info,
      ),
      (context) => FaqQuestion(
        question: context.l10n.faq_question_which_medications,
        answer: context.l10n.faq_answer_which_medications,
        answerWidgets: [
          IncludedContentDisclaimerCard(
            type: ListInclusionDescriptionType.medications,
          ),
        ],
        widgetsBeforeText: true,
      ),
      // If inhibitors for other genes than CYP2D6 are implemented, this needs
      // to be updated (e.g., by reverting this commit): adapt description of 
      // included items in user instructions and FAQ answer
      (context) => FaqQuestion(
        question: context.l10n.faq_question_phenoconversion,
        answer: context.l10n.faq_answer_phenoconversion,
        answerWidgets: inhibitableGenes.map(
          (geneName) => GeneModulatorList(
            geneName: geneName,
            showGeneName: false,
          ).widget,
        ),
      ),
      (context) => FaqQuestion(
        question: context.l10n.faq_question_family,
        answer: context.l10n.faq_answer_family,
      ),
      (context) => FaqQuestion(
        question: context.l10n.faq_question_share,
        answer: context.l10n.faq_answer_share,
      ),
    ],
  ),
];
