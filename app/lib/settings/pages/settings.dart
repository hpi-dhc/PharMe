import 'package:comprehension_measurement/comprehension_measurement.dart';

import '../../common/module.dart';
import '../utils.dart';

class SettingsPage extends AutoComprehensiblePage {
  SettingsPage()
      : super(
          supabaseConfig: supabaseConfig,
          surveyId: 1,
          introText:
              '''Would you like to participate in a survey with the aim to measure user comprehension 
                of the applications content? This would help the developer team greatly to improve PharMe 
                and make it understandable for everyone!''',
          surveyButtonText: 'Continue to survey',
          probability: 1,
          didOpenTab: (previousRoute) {
            return previousRoute == AutoRoute(path: 'main/reports/');
          },
        );

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      ListTile(
        title: Text(
          context.l10n.settings_page_account_settings,
          style: PharmeTheme.textTheme.bodyLarge,
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
      Divider(),
      ListTile(
        title: Text(
          context.l10n.settings_page_more,
          style: PharmeTheme.textTheme.bodyLarge,
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
        onTap: () => context.router
            .push(TermsAndConditionsRoute(comprehensionContext: context)),
      ),
      Divider(),
      ListTile(
        title: Text(
          'Comprehension Measurment',
          style: PharmeTheme.textTheme.bodyLarge,
        ),
      ),
      ListTile(
        title: Text('Measure comprehension'),
        trailing: Icon(Icons.chevron_right),
        onTap: () => measureComprehension(
          context: context,
          surveyId: 1,
          introText: 'Was the last page understandable for you?',
          surveyButtonText: 'Yes',
          feedbackButtonText: 'No',
          supabaseConfig: supabaseConfig,
        ),
      ),
    ]);
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
