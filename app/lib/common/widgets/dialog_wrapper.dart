import '../module.dart';

class DialogWrapper extends StatelessWidget {
  const DialogWrapper({
    super.key,
    required this.actions,
    this.title,
    this.content,
  });

  final String? title;
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
      title: title != null ? Text(title!) : null,
      content: materialContent,
      actions: actions,
      elevation: 0,
    );
  }
}
