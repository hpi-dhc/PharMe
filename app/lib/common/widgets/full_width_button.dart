import '../module.dart';

class FullWidthButton extends StatelessWidget {
  const FullWidthButton(
    this.text,
    this.action, {
    super.key,
    this.enabled = true,
    this.secondaryColor = false,
  });

  final bool enabled;
  final String text;
  final void Function() action;
  final bool secondaryColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? action : null,
        style: ButtonStyle(
          backgroundColor:
            MaterialStateProperty.all<Color>(secondaryColor
              ? PharMeTheme.secondaryColor
              : PharMeTheme.primaryColor
            ),
        ),
        child: Text(text, style: PharMeTheme.textTheme.bodyLarge),
      ),
    );
  }
}