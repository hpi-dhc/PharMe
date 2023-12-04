import 'package:flutter/cupertino.dart';

import '../../../module.dart';

class AdaptiveAlertDialog extends StatelessWidget {
  const AdaptiveAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  final String title;
  final Widget? content;
  final List<AdaptiveDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    switch (getPlatform()) {
      case SupportedPlatform.android:
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: actions,
        );
      case SupportedPlatform.ios:
        return CupertinoAlertDialog(
          title: Text(title),
          content: Card(
            color: Colors.transparent,
            elevation: 0,
            child: content,
          ),
          actions: actions,
        );
    }
  }
}

class AdaptiveDialogAction extends StatelessWidget {
  const AdaptiveDialogAction({
    Key? key,
    this.isDefault = false,
    this.isDestructive = false,
    this.onPressed,
    required this.text,
  }) : super(key: key);

  final bool isDefault;
  final bool isDestructive;
  final void Function()? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    switch (getPlatform()) {
      case SupportedPlatform.android:
        return TextButton(
          onPressed: onPressed,
          child: Text(text, style: onPressed != null
              ? isDestructive
                ? TextStyle(color: PharMeTheme.errorColor)
                : TextStyle(color: PharMeTheme.primaryColor)
              : TextStyle(color: PharMeTheme.onSurfaceColor)),
        );
      case SupportedPlatform.ios:
        return CupertinoDialogAction(
          isDefaultAction: isDefault,
          isDestructiveAction: isDestructive,
          onPressed: onPressed,
          child: Text(text),
        );
    }
  }
}

Future<dynamic> showAdaptiveDialog({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) {
  switch (getPlatform()) {
    case SupportedPlatform.android:
      return showDialog(context: context, builder: builder);
    case SupportedPlatform.ios:
      return showCupertinoDialog(context: context, builder: builder);
  }
}