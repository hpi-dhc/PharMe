import '../../common/module.dart';
import 'content.dart';

@RoutePage()
class FaqPage extends HookWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqContent = getFaqContent();
    final expandedCards = useState<Map<String, GlobalKey>>({});
    final expandQuestion = useState<String?>(null);
    if (expandQuestion.value != null) {
        final questionKey = GlobalKey();
        expandedCards.value[expandQuestion.value!] = questionKey;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (expandQuestion.value != null) {
        _scrollToSelectedContent(
          key: expandedCards.value[expandQuestion.value]!,
        );
        expandQuestion.value = null;
      }
    });
    return PopScope(
      canPop: false,
      child: pageScaffold(
        title: context.l10n.tab_faq,
        canNavigateBack: false,
        body: [
          Padding(
            padding: const EdgeInsets.only(
              left: PharMeTheme.smallSpace,
              right: PharMeTheme.smallSpace,
              bottom: PharMeTheme.smallSpace,
            ),
            child: Column(
              key: Key('questionsColumn'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...faqContent.flatMap((faqSection) =>
                  _buildTopic(
                    context,
                    faqSection,
                    expandedCards,
                    expandQuestion,
                    faqContent,
                  )),
                ..._buildTopicHeader(
                  context.l10n.more_page_contact_us,
                  addSpace: true,
                ),
                _buildQuestionCard(
                  child: ListTile(
                    title: Text(context.l10n.faq_contact_us),
                    trailing: Icon(Icons.chevron_right_rounded),
                    iconColor: PharMeTheme.iconColor,
                    onTap: () => sendEmail(context),
                  )
                ),
            ],
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildTopicHeader(String title, { required bool addSpace }) => [
    if (addSpace) SizedBox(height: PharMeTheme.mediumSpace),
    SubheaderDivider(text: title, useLine: false),
  ];

  Widget _buildQuestionCard({ required Widget child, Key? key }) => RoundedCard(
    key: key,
    innerPadding: EdgeInsets.all(PharMeTheme.smallSpace * 0.25),
    child: child,
  );

  List<Widget> _buildTopic(
    BuildContext context,
    FaqSection faqSection,
    ValueNotifier<Map<String, GlobalKey>> expandedCards,
    ValueNotifier<String?> expandQuestion,
    List<FaqSection> faqContent,
  ) {
    final isFirst = faqContent.indexOf(faqSection) == 0;
    return [
      ..._buildTopicHeader(faqSection.title(context), addSpace: !isFirst),
      ...faqSection.questions.map(
        (questionBuilder) =>
          _buildQuestion(context, questionBuilder, expandedCards, expandQuestion)
      )
    ];
  }

  Widget _buildQuestion(
    BuildContext context,
    FaqQuestionBuilder questionBuilder,
    ValueNotifier<Map<String, GlobalKey>> expandedCards,
    ValueNotifier<String?> expandQuestion,
  ) {
    final question = questionBuilder(context);
    final key = expandedCards.value[question.question];
    final expanded = expandedCards.value.containsKey(question.question);
    return _buildQuestionCard(
          key: key,
          child: PrettyExpansionTile(
            initiallyExpanded: expanded,
            title: Text(
              question.question,
              style: expanded
                ? PharMeTheme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                )
                : null,
            ),
            onExpansionChanged: (value) {
              if (value) {
                expandQuestion.value = question.question;
              } else {
                expandedCards.value = expandedCards.value.filterKeys(
                  (questionTitle) => questionTitle != question.question
                );
              }
            },
            children: [
              ListTile(
                contentPadding: EdgeInsets.only(
                  left: PharMeTheme.mediumSpace,
                  right: PharMeTheme.mediumSpace,
                  bottom: PharMeTheme.smallSpace,
                ),
                title: question is FaqTextAnswerQuestion
                  ? LargeMarkdownBody(data: question.answer)
                  : question.answer,
              ),
            ],
          ),
        );
  }

  void _scrollToSelectedContent({required GlobalKey key}) {
    final keyContext = key.currentContext;
    if (keyContext != null) {
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        Scrollable.ensureVisible(
          // ignore: use_build_context_synchronously
          keyContext,
          duration: Duration(milliseconds: 500),
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      });
    }
  }
}
