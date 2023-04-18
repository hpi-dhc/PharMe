import '../../common/module.dart';
import '../utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return pageScaffold(title: context.l10n.tab_more, body: [
      ListTile(
        title: Text(
          context.l10n.settings_page_account_settings,
          style: PharMeTheme.textTheme.bodyMedium,
        ),
        dense: true,
      ),
      ListTile(
        title: Text(context.l10n.settings_page_delete_data),
        trailing: Icon(Icons.chevron_right_rounded),
        onTap: () => showDialog(
          context: context,
          builder: (_) => _deleteDataDialog(context),
        ),
      ),
      Divider(),
      ListTile(
        title: Text(
          context.l10n.settings_page_more,
          style: PharMeTheme.textTheme.bodyMedium,
        ),
        dense: true,
      ),
      ListTile(
        title: Text(context.l10n.settings_page_onboarding),
        trailing: Icon(Icons.chevron_right_rounded),
        onTap: () => context.router.push(OnboardingRouter()),
      ),
      ListTile(
        title: Text(context.l10n.settings_page_about_us),
        trailing: Icon(Icons.chevron_right_rounded),
        onTap: () => context.router.push(AboutUsRoute()),
      ),
      ListTile(
        title: Text(context.l10n.settings_page_privacy_policy),
        trailing: Icon(Icons.chevron_right_rounded),
        onTap: () => context.router.push(PrivacyPolicyRoute()),
      ),
      ListTile(
        title: Text(context.l10n.settings_page_terms_and_conditions),
        trailing: Icon(Icons.chevron_right_rounded),
        onTap: () => context.router.push(TermsAndConditionsRoute()),
      ),
      Divider(),
      ListTile(
          title: Text(context.l10n.settings_page_contact_us),
          trailing: Icon(Icons.chevron_right_rounded),
          onTap: sendEmail)
    ]);
  }

  Widget _deleteDataDialog(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.settings_page_delete_data),
      content: Text(context.l10n.settings_page_delete_data_text),
      actions: [
        TextButton(
          onPressed: context.router.root.pop,
          child: Text(context.l10n.action_cancel),
        ),
        TextButton(
          onPressed: () async {
            await deleteAllAppData();
            await context.router.replaceAll([LoginRouter()]);
          },
          child: Text(
            context.l10n.action_continue,
            style: TextStyle(color: PharMeTheme.errorColor),
          ),
        ),
      ],
    );
  }
}
