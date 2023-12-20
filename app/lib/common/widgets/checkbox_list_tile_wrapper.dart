import '../module.dart';

class CheckboxListTileWrapper extends StatelessWidget {
  const CheckboxListTileWrapper({
    super.key,
    required this.title,
    required this.isChecked,
    required this.onChanged,
    this.subtitle,
    this.isEnabled = true,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.contentPadding,
    this.activeColor,
  });

  final String title;
  final String? subtitle;
  final bool isChecked;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool?)? onChanged;
  final bool isEnabled;
  final ListTileControlAffinity controlAffinity;
  final EdgeInsetsGeometry? contentPadding;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile.adaptive(
      enabled: isEnabled,
      value: isChecked,
      onChanged: onChanged,
      title: Text(title, style: PharMeTheme.textTheme.bodyLarge),
      subtitle: subtitle != null
        ? Text(subtitle!, style: PharMeTheme.textTheme.bodyMedium)
        : null,
      controlAffinity: controlAffinity,
      contentPadding: contentPadding,
      activeColor: activeColor ?? PharMeTheme.primaryColor,
    );  }

}