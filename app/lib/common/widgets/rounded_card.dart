import '../module.dart';
import '../utilities/color_utils.dart';

class RoundedCard extends StatelessWidget {
  const RoundedCard({
    this.innerPadding,
    this.outerVerticalPadding,
    this.outerHorizontalPadding,
    this.color,
    this.radius,
    this.onTap,
    required this.child,
    super.key,
  });

  final EdgeInsets? innerPadding;
  final double? outerVerticalPadding;
  final double? outerHorizontalPadding;
  final VoidCallback? onTap;
  final Color? color;
  final double? radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(
      padding: innerPadding ?? EdgeInsets.all(PharMeTheme.smallToMediumSpace),
      child: this.child,
    );

    if (onTap != null) child = InkWell(onTap: onTap, child: child);

    // ignore: sized_box_for_whitespace
    return Container(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: outerVerticalPadding ?? PharMeTheme.smallSpace * 0.65,
          horizontal: outerHorizontalPadding ?? PharMeTheme.smallSpace,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color ?? darkenColor(PharMeTheme.onSurfaceColor, -0.05),
            borderRadius: BorderRadius.all(
              Radius.circular(radius ?? PharMeTheme.outerCardRadius)
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
