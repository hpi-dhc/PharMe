import '../../common/module.dart';

@RoutePage()
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return pageScaffold(
        title: context.l10n.more_page_terms_and_conditions,
        body: [
          Container(
            color: PharMeTheme.backgroundColor,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                    context.l10n.more_page_terms_and_conditions_text,
                    style: PharMeTheme.textTheme.bodyLarge)),
          ),
        ]);
  }
}
