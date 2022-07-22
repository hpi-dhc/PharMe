import '../../common/module.dart';
import '../constants.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          key: Key('questions_column'),
          children: [
            _buildHeaderCard(context),
            SizedBox(height: 8),
            ...faqList.map((item) => _buildQuestion(context, item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      height: 150,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PharMeTheme.primaryColor.shade500,
            PharMeTheme.primaryColor.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SvgPicture.asset(
              'assets/images/pgx_faq.svg',
              width: 120,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.faq_pharmacogenomics,
                  style: PharMeTheme.textTheme.titleLarge!
                      .copyWith(color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  context.l10n.faq_page_description,
                  style: PharMeTheme.textTheme.bodyMedium!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
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
