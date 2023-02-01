import '../module.dart';

class RoundedCard extends StatelessWidget {
  RoundedCard({
    this.padding = const EdgeInsets.all(16),
    this.color = PharMeTheme.surfaceColor,
    this.onTap,
    required this.child,
  });

  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final Widget child;

  final borderRadius = BorderRadius.all(
    Radius.circular(20),
  );

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(padding: padding, child: this.child);

    if (onTap != null) child = InkWell(onTap: onTap, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(width: 0.5, color: PharMeTheme.borderColor),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: PharMeTheme.onSurfaceColor,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
