import '../../common/module.dart';

class TooltipIcon extends StatelessWidget {
  const TooltipIcon(this.message, { this.size = 16 });

  final String message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tooltipKey = GlobalKey<TooltipState>();
    return Tooltip(
      key: tooltipKey,
      message: message,
      margin: EdgeInsets.symmetric(horizontal: PharMeTheme.smallToMediumSpace),
      padding: EdgeInsets.all(PharMeTheme.smallSpace),
      triggerMode: TooltipTriggerMode.manual,
      child: SizedBox(
        height: size,
        width: size,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => tooltipKey.currentState?.ensureTooltipVisible(),
          icon: Icon(
            Icons.help_outline_rounded,
            size: size,
            color: PharMeTheme.iconColor,
          ),
          style: ButtonStyle(
            fixedSize: WidgetStateProperty.all(Size.fromHeight(size)),
          ),
        ),
      ),
    );
  }
}
