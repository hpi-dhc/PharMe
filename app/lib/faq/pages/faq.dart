import '../../common/module.dart';
import '../constants.dart';

@RoutePage()
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: pageScaffold(title: context.l10n.tab_faq, body: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            key: Key('questionsColumn'),
            children: [
              SizedBox(height: 8),
              ...faqList.keys.fold<List<Widget>>(
                [], (widgets, topic) =>
                  [...widgets, ..._buildTopic(context, topic, faqList[topic]!)]
              ),
              Divider(),
              ListTile(
                  title: Text(context.l10n.faq_contact_us),
                  trailing: Icon(Icons.chevron_right_rounded),
                  onTap: sendEmail)
            ],
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildTopic(
    BuildContext context,
    String topicName,
    List<Question> questions
  ) {
    return [
      ListTile(
        title: Text(
          topicName,
          style: PharMeTheme.textTheme.bodyMedium,
        ),
        dense: true,
      ),
      ...questions.map((question) => _buildQuestion(context, question))
    ];
  }

  Widget _buildQuestion(BuildContext context, Question question) {
    final key = GlobalKey();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        key: key,
        title: Text(question.question),
        onExpansionChanged: (value) {
          if (value) _scrollToSelectedContent(key: key);
        },
        children: [
          ListTile(
            contentPadding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
            title: Text(question.answer),
          ),
        ],
      ),
    );
  }

  void _scrollToSelectedContent({required GlobalKey key}) {
    final keyContext = key.currentContext;
    if (keyContext != null) {
      Future.delayed(Duration(milliseconds: 200)).then((value) {
        Scrollable.ensureVisible(
          keyContext,
          duration: Duration(milliseconds: 200),
        );
      });
    }
  }
}
