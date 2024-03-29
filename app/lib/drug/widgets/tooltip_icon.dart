import '../../common/module.dart';

class TooltipIcon extends StatelessWidget {
  const TooltipIcon(this.message, { this.size = 16 });

  final String message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      margin: EdgeInsets.all(PharMeTheme.smallSpace),
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 3),
      child: Icon(Icons.help_outline_rounded, size: size),
    );
  }
}
