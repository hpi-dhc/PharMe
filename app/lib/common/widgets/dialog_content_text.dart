import '../module.dart';

class DialogContentText extends StatelessWidget {
  const DialogContentText(this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: PharMeTheme.textTheme.bodyLarge);
  }
}