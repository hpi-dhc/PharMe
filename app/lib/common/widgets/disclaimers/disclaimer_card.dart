import '../../module.dart';

class DisclaimerCard extends StatelessWidget {
  const DisclaimerCard({
    this.icon,
    this.iconSize = 32.0,
    this.iconWidget,
    this.text,
    this.textWidget,
    this.secondLineText,
    this.onClick,
    this.iconPadding,
    this.color,
    this.elevation,
  });

  final IconData? icon;
  final double iconSize;
  final Widget? iconWidget;
  final String? text;
  final Widget? textWidget;
  final String? secondLineText;
  final GestureTapCallback? onClick;
  final EdgeInsets? iconPadding;
  final Color? color;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final widget = Card(
      color: color ?? PharMeTheme.surfaceColor,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(PharMeTheme.smallSpace),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: iconPadding ?? EdgeInsets.zero,
              child: iconWidget ?? Icon(
                icon ?? Icons.warning_rounded,
                size: iconSize,
                color: PharMeTheme.onSurfaceText,
              ),
            ),
            SizedBox(width: PharMeTheme.smallSpace),
            Expanded(
              child: Column(
                children: [
                  textWidget ?? getTextWidget(text!),
                  if (secondLineText != null) ...[
                    SizedBox(height: PharMeTheme.smallSpace),
                    getTextWidget(secondLineText!),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onClick != null) return InkWell(onTap: onClick, child: widget);

    return widget;
  }

  Widget getTextWidget(String text) => Text(
    text,
    style: PharMeTheme.textTheme.bodyMedium,
    textAlign: TextAlign.start,
  );
}