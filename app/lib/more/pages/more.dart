import '../../common/module.dart';
import '../utils.dart';

@RoutePage()
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: pageScaffold(title: context.l10n.tab_more, body: [
        ListTile(
          title: Text(
            context.l10n.settings_page_account_settings,
            style: PharMeTheme.textTheme.bodyMedium,
          ),
          dense: true,
        ),
        ListTile(
          title: Text(context.l10n.drug_selection_header),
          trailing: Icon(Icons.chevron_right_rounded),
          onTap: () => context.router.push(
            DrugSelectionRoute(concludesOnboarding: false)
          ),
        ),
        ListTile(
          title: Text(context.l10n.settings_page_delete_data),
          trailing: Icon(Icons.chevron_right_rounded),
          onTap: () => showDialog(
            context: context,
            builder: (_) => DeleteDataDialog(),
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
          onTap: () => context.router.push(OnboardingRoute(isRevisiting: true)),
        ),
        ListTile(
          title: Text(context.l10n.settings_page_about_us),
          trailing: Icon(Icons.chevron_right_rounded),
          onTap: () => context.router.push(AboutRoute()),
        ),
        ListTile(
          title: Text(context.l10n.settings_page_privacy_policy),
          trailing: Icon(Icons.chevron_right_rounded),
          onTap: () => context.router.push(PrivacyRoute()),
        ),
        ListTile(
          title: Text(context.l10n.settings_page_terms_and_conditions),
          trailing: Icon(Icons.chevron_right_rounded),
          onTap: () => context.router.push(TermsRoute()),
        ),
        Divider(),
        ListTile(
            title: Text(context.l10n.settings_page_contact_us),
            trailing: Icon(Icons.chevron_right_rounded),
            onTap: sendEmail)
      ]),
    );
  }
}

class DeleteDataDialog extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final agreedToDeletion = useState(false);

    return DialogWrapper(
      title: context.l10n.settings_page_delete_data,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogContentText(context.l10n.settings_page_delete_data_text),
          SizedBox(height: PharMeTheme.mediumSpace),
          DialogContentText(
            context.l10n.settings_page_delete_data_additional_text,
          ),
          SizedBox(height: PharMeTheme.mediumSpace),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: PharMeTheme.mediumToLargeSpace,
                height: PharMeTheme.mediumToLargeSpace,
                child: Checkbox.adaptive(
                  value: agreedToDeletion.value,
                  onChanged: (value) =>
                    agreedToDeletion.value = value ?? agreedToDeletion.value,
                ),
              ),
              SizedBox(width: PharMeTheme.smallSpace),
              Expanded(
                child: DialogContentText(
                  context.l10n.settings_page_delete_data_confirmation,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        DialogAction(
          onPressed: context.router.root.pop,
          text: context.l10n.action_cancel,
        ),
        DialogAction(
          onPressed: agreedToDeletion.value
            ? () async {
              await deleteAllAppData();
              // ignore: use_build_context_synchronously
              await overwriteRoutes(context, nextPage: LoginRoute());
            }
            : null,
          text: context.l10n.action_continue,
          isDestructive: true,
        ),
      ],
    );
  }
}
