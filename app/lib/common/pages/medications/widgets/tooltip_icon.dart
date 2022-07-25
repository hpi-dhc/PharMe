import 'package:flutter/material.dart';

class TooltipIcon extends StatelessWidget {
  const TooltipIcon(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 2),
      child: Icon(Icons.help_outline_rounded, size: 16),
    );
  }
}
