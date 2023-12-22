import '../module.dart';

class CheckboxWrapper extends StatelessWidget {
  const CheckboxWrapper({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.isEnabled = true,
  });

  final bool isChecked;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool?)? onChanged;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Checkbox.adaptive(
      value: isChecked,
      onChanged: isEnabled ? onChanged : null,
      activeColor: PharMeTheme.primaryColor,
      checkColor: Colors.white,
      side: isChecked || !isEnabled
        ? null
        : BorderSide(color: darkenColor(PharMeTheme.iconColor, -0.15)),
    );
  }
}