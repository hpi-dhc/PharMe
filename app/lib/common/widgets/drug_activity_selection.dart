import '../module.dart';

typedef SetDrugActivityFunction = void Function({
  required Drug drug,
  required bool? value,
});

SwitchListTile buildDrugActivitySelection({
  Key? key,
  required BuildContext context,
  required Drug drug,
  required String title,
  String? subtitle,
  required SetDrugActivityFunction setActivity,
  required bool isActive,
  required bool disabled,
  EdgeInsetsGeometry? contentPadding,
}) => SwitchListTile.adaptive(
  key: key,
  value: isActive,
  activeColor: PharMeTheme.primaryColor,
  title: Text(title),
  subtitle: subtitle.isNotNullOrBlank ? Text(subtitle!, style: PharMeTheme.textTheme.bodyMedium): null,
  contentPadding: contentPadding,
  onChanged: disabled ? null : (newValue) {
    if (isInhibitor(drug.name)) {
      showAdaptiveDialog(
        context: context,
        builder: (context) => DialogWrapper(
          title: context.l10n.drugs_page_active_warn_header,
          content: DialogContentText(
            context.l10n.drugs_page_active_warn,
          ),
          actions: [
            DialogAction(
              onPressed: () => Navigator.pop(
                context,
                'Cancel',
              ),
              text: context.l10n.action_cancel,
            ),
            DialogAction(
              onPressed: () {
                Navigator.pop(context, 'OK');
                setActivity(drug: drug, value: newValue);
              },
              text: context.l10n.action_continue,
              isDestructive: true,
            ),
          ],
        ),
      );
    } else {
      setActivity(drug: drug, value: newValue);
    }
  },
);