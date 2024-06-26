import '../../common/module.dart';

@RoutePage()
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return pageScaffold(title: context.l10n.more_page_privacy_policy, body: [
      Container(
        color: PharMeTheme.backgroundColor,
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.l10n.more_page_privacy_policy_text,
                style: PharMeTheme.textTheme.bodyLarge)),
      ),
    ]);
  }
}
