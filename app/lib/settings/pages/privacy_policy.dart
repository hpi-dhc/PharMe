import '../../common/module.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

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
              context.l10n.settings_page_privacy_policy,
              style: PharmeTheme.textTheme.headlineSmall,
            ),
          ),
          Text(context.l10n.settings_page_privacy_policy_text)
        ],
      ),
    );
  }
}
