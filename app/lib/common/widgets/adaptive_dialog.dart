import 'package:flutter/cupertino.dart';

import '../module.dart';

class AdaptiveDialogWrapper extends StatelessWidget {
  const AdaptiveDialogWrapper({
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
    );
  }
}

class DialogAction extends StatelessWidget {
  const DialogAction({
    super.key,
    this.isDestructive = false,
    this.onPressed,
    required this.text,
  });

  final bool isDestructive;
  final void Function()? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    switch (getPlatform()) {        
      case SupportedPlatform.ios:
        return CupertinoDialogAction(
          isDestructiveAction: isDestructive,
          onPressed: onPressed,
          child: Text(text),
        );
      default:
        return TextButton(
          onPressed: onPressed,
          child: Text(text, style: onPressed != null
              ? isDestructive
                ? TextStyle(color: PharMeTheme.errorColor)
                : TextStyle(color: PharMeTheme.primaryColor)
              : TextStyle(color: PharMeTheme.onSurfaceColor)),
        );
    }
  }
}
