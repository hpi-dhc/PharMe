import '../module.dart';

class FullWidthButton extends StatelessWidget {
  const FullWidthButton(
    this.text,
    this.action, {
    Key? key,
  }) : super(key: key);

  final String text;
  final void Function() action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: action,
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