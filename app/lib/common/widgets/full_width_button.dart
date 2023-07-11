import '../module.dart';

class FullWidthButton extends StatelessWidget {
  const FullWidthButton(
    this.text,
    this.action, {
    Key? key,
    this.enabled = true,
  }) : super(key: key);

  final bool enabled;
  final String text;
  final void Function() action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? action : null,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}