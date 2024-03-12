import '../module.dart';

class CheckboxListTileWrapper extends StatelessWidget {
  const CheckboxListTileWrapper({
    super.key,
    required this.title,
    required this.isChecked,
    required this.onChanged,
    this.subtitle,
    this.isEnabled = true,
    this.contentPadding,
  });

  final String title;
  final String? subtitle;
  final bool isChecked;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool?) onChanged;
  final bool isEnabled;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: isEnabled,
      title: Text(title, style: PharMeTheme.textTheme.bodyLarge),
      subtitle: subtitle != null
        ? Text(subtitle!, style: PharMeTheme.textTheme.bodyMedium)
        : null,
      contentPadding: contentPadding,
      onTap: () => isEnabled ? onChanged(!isChecked) : null,
      leading: CheckboxWrapper(
        isEnabled: isEnabled,
        isChecked: isChecked,
        onChanged: onChanged,
      ),
    );
  }
}