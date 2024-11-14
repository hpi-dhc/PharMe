import '../module.dart';

class FullWidthButton extends StatelessWidget {
  const FullWidthButton(
    this.text,
    this.action, {
    super.key,
    this.enabled = true,
    this.color,
  });

  final bool enabled;
  final String text;
  final void Function() action;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final buttonBaseColor = color ?? PharMeTheme.primaryColor;
    final buttonColor = enabled
      ? buttonBaseColor
      : darkenColor(buttonBaseColor, -0.4);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? action : null,
        style: ButtonStyle(
          backgroundColor:
            WidgetStateProperty.all<Color>(buttonColor),
        ),
        child: Text(
          text,
          style: PharMeTheme.textTheme.bodyLarge!.copyWith(
            color: enabled
              ? PharMeTheme.textTheme.bodyLarge!.color
              : Colors.grey.shade400,
          )),
      ),
    );
  }
}