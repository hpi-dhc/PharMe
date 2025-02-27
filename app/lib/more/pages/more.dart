import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../common/module.dart';
import '../../common/utilities/hive_utils.dart';

@RoutePage()
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: pageScaffold(
        title: context.l10n.tab_more,
        canNavigateBack: false,
        body: [
          SubheaderDivider(
            text: context.l10n.more_page_account_settings,
            useLine: false,
          ),
          _buildSettingsItem(
            title: context.l10n.more_page_edit_current_medications,
            onTap: () => context.router.push(
              DrugSelectionRoute(concludesOnboarding: false)
            ),
          ),
          _buildSettingsItem(
            title: context.l10n.more_page_delete_data,
            onTap: () => showDialog(
              context: context,
              builder: (_) => DeleteDataDialog(),
            ),
          ),
          SubheaderDivider(
            text: context.l10n.more_page_help_and_feedback,
            useLine: false,
          ),
           _buildSettingsItem(
              title: context.l10n.more_page_contact_us,
              onTap: () => sendEmail(context)),
          _buildSettingsItem(
            title: context.l10n.more_page_onboarding,
            onTap: () =>
              context.router.push(OnboardingRoute(isRevisiting: true)),
          ),
          _buildSettingsItem(
            title: context.l10n.more_page_app_tour,
            onTap: () async => showAppTour(
              context,
              lastNextButtonText: context.l10n.action_back_to_app,
              revisiting: true,
            ),
          ),
          _buildSettingsItem(
              title: context.l10n.more_page_genetic_information,
              onTap: () => context.router.push(
                GeneticInformationRoute(),
              ),
          ),
          SubheaderDivider(
            text: context.l10n.more_page_app_information,
            useLine: false,
          ),
          _buildSettingsItem(
            title: context.l10n.more_page_about_us,
            onTap: () => context.router.push(AboutRoute()),
          ),
          _buildSettingsItem(
            title: context.l10n.more_page_privacy_policy,
            onTap: () => context.router.push(PrivacyRoute()),
          ),
          _buildSettingsItem(
            title: context.l10n.more_page_terms_and_conditions,
            onTap: () => context.router.push(TermsRoute()),
          ),
          if (kDebugMode) SubheaderDivider(
            text: 'Test Error Handling',
            useLine: false,
          ),
          if (kDebugMode) _buildSettingsItem(
            title: 'Throw Flutter Error',
            style: TextStyle(color: PharMeTheme.errorColor),
            onTap: () => throw FlutterError(nonFatalTestErrorMessage),
          ),
          if (kDebugMode) _buildSettingsItem(
            title: 'Throw Other Error',
            style: TextStyle(color: PharMeTheme.errorColor),
            onTap: () async => throw Exception(nonFatalTestErrorMessage),
          ),
          if (kDebugMode) _buildSettingsItem(
            title: 'Throw Flutter Error (Fatal)',
            style: TextStyle(color: PharMeTheme.errorColor),
            onTap: () => throw FlutterError(fatalTestErrorMessage),
          ),
          if (kDebugMode) _buildSettingsItem(
            title: 'Throw Other Error (Fatal)',
            style: TextStyle(color: PharMeTheme.errorColor),
            onTap: () async => throw Exception(fatalTestErrorMessage),
          ),
        ]
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required void Function() onTap,
    TextStyle? style,
  }) => ListTile(
    title: Text(title, style: style),
    trailing: Icon(Icons.chevron_right_rounded),
    iconColor: PharMeTheme.iconColor,
    onTap: onTap,
  );
}

class DeleteDataDialog extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final agreedToDeletion = useState(false);

    return DialogWrapper(
      title: context.l10n.more_page_delete_data,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogContentText(context.l10n.more_page_delete_data_text),
          SizedBox(height: PharMeTheme.mediumSpace),
          DialogContentText(
            context.l10n.more_page_delete_data_additional_text,
          ),
          SizedBox(height: PharMeTheme.mediumSpace),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: PharMeTheme.mediumToLargeSpace,
                height: PharMeTheme.mediumToLargeSpace,
                child: CheckboxWrapper(
                  isChecked: agreedToDeletion.value,
                  onChanged: (value) =>
                    agreedToDeletion.value = value ?? agreedToDeletion.value,
                ),
              ),
              SizedBox(width: PharMeTheme.smallSpace),
              Expanded(
                child: DialogContentText(
                  context.l10n.more_page_delete_data_confirmation,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        DialogAction(
          onPressed: context.router.root.maybePop,
          text: context.l10n.action_cancel,
        ),
        DialogAction(
          onPressed: agreedToDeletion.value
            ? () async {
              await deleteAllAppData();
              // ignore: use_build_context_synchronously
              await context.router.root.maybePop();
              // ignore: use_build_context_synchronously
              await showAdaptiveDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (context) => DialogWrapper(
                  title: context.l10n.delete_data_restart_title,
                  content:
                    DialogContentText(context.l10n.delete_data_restart_text),
                  actions: [
                    DialogAction(
                      text: context.l10n.error_close_app,
                      onPressed: () => exit(0),
                    ),
                  ],
                ),
              );
            }
            : null,
          text: context.l10n.action_continue,
          isDestructive: true,
        ),
      ],
    );
  }
}
