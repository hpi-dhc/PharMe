import 'dart:io';

import '../../common/module.dart';
import '../chdp_state.dart';
import '../utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: [
      ListTile(
        title: Text(
          context.l10n.settings_page_account_settings,
          style: PharMeTheme.textTheme.bodyLarge,
        ),
      ),
      ListTile(
        title: Text(context.l10n.settings_page_delete_data),
        trailing: Icon(Icons.chevron_right),
        onTap: () => showDialog(
          context: context,
          builder: (_) => _deleteDataDialog(context),
        ),
      ),
      if (Platform.isAndroid)
        ChdpListTile()
      else
        null,
      Divider(),
      ListTile(
        title: Text(
          context.l10n.settings_page_more,
          style: PharMeTheme.textTheme.bodyLarge,
        ),
      ),
      ListTile(
        title: Text(context.l10n.settings_page_onboarding),
        trailing: Icon(Icons.chevron_right),
        onTap: () => context.router.push(OnboardingRouter()),
      ),
      ListTile(
        title: Text(context.l10n.settings_page_about_us),
        trailing: Icon(Icons.chevron_right),
        onTap: () => context.router.push(AboutUsRoute()),
      ),
      ListTile(
        title: Text(context.l10n.settings_page_privacy_policy),
        trailing: Icon(Icons.chevron_right),
        onTap: () => context.router.push(PrivacyPolicyRoute()),
      ),
      ListTile(
        title: Text(context.l10n.settings_page_terms_and_conditions),
        trailing: Icon(Icons.chevron_right),
        onTap: () => context.router.push(TermsAndConditionsRoute()),
      ),
    ].whereType<Widget>().toList());
  }

  Widget _deleteDataDialog(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.settings_page_delete_data),
      content: Text(context.l10n.settings_page_delete_data_text),
      actions: [
        TextButton(
          onPressed: context.router.root.pop,
          child: Text(context.l10n.settings_page_cancel),
        ),
        TextButton(
          onPressed: () async {
            await deleteAllAppData();
            await context.router.replaceAll([LoginRouter()]);
          },
          child: Text(
            context.l10n.settings_page_continue,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
