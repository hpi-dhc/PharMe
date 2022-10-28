import '../../common/module.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return pageScaffold(
        title: context.l10n.settings_page_terms_and_conditions,
        body: [
          Container(
            color: PharMeTheme.backgroundColor,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                    context.l10n.settings_page_terms_and_conditions_text,
                    style: PharMeTheme.textTheme.bodyLarge)),
          ),
        ]);
  }
}
