import '../module.dart';

class RoundedCard extends StatelessWidget {
  const RoundedCard({
    this.innerPadding,
    this.outerPadding,
    this.color = PharMeTheme.surfaceColor,
    this.radius = 20,
    this.onTap,
    required this.child,
  });

  final EdgeInsets? innerPadding;
  final EdgeInsets? outerPadding;
  final VoidCallback? onTap;
  final Color color;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(
      padding: innerPadding ?? EdgeInsets.all(PharMeTheme.mediumSpace),
      child: this.child,
    );

    if (onTap != null) child = InkWell(onTap: onTap, child: child);

    // ignore: sized_box_for_whitespace
    return Container(
      width: double.infinity,
      child: Padding(
        padding: outerPadding ?? EdgeInsets.symmetric(
          horizontal: PharMeTheme.smallSpace,
          vertical: PharMeTheme.smallSpace / 2
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(radius)),
            boxShadow: [
              BoxShadow(
                color: PharMeTheme.onSurfaceColor,
                blurRadius: 16,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
