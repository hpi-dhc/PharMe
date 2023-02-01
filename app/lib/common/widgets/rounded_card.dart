import '../module.dart';

class RoundedCard extends StatelessWidget {
  const RoundedCard({
    this.padding = const EdgeInsets.all(16),
    this.color = PharMeTheme.surfaceColor,
    this.radius = 20,
    this.onTap,
    required this.child,
  });

  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(padding: padding, child: this.child);

    if (onTap != null) child = InkWell(onTap: onTap, child: child);

    // ignore: sized_box_for_whitespace
    return Container(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(width: 0.5, color: PharMeTheme.borderColor),
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          boxShadow: [
            BoxShadow(
              color: PharMeTheme.onSurfaceColor,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
