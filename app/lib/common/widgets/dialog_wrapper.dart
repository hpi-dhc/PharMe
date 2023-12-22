import '../module.dart';

class DialogWrapper extends StatelessWidget {
  const DialogWrapper({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  final String title;
  final Widget? content;
  final List<DialogAction> actions;

  @override
  Widget build(BuildContext context) {
    final materialContent = getPlatform() == SupportedPlatform.ios
      ? Card(
          color: Colors.transparent,
          elevation: 0,
          child: content,
        )
      : content;
    return AlertDialog.adaptive(
      title: Text(title),
      content: materialContent,
      actions: actions,
      elevation: 0,
    );
  }
}
