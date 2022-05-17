import '../../common/module.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 16),
            child: Text(
              context.l10n.settings_page_terms_and_conditions,
              style: PharmeTheme.textTheme.headlineSmall,
            ),
          ),
          Text(context.l10n.settings_page_terms_and_conditions_text)
        ],
      ),
    );
  }
}
