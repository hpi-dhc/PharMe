import '../module.dart';

Widget defaultIconBuilder(IconData icon, double? size) => Icon(
  icon,
  size: size,
  color: PharMeTheme.iconColor,
);

class ResizedIconButton extends StatelessWidget {
  const ResizedIconButton({
    super.key,
    required this.iconWidgetBuilder,
    required this.size,
    this.onPressed,
    this.backgroundColor,
    this.disabledBackgroundColor,
  });

  final Widget Function(double? size) iconWidgetBuilder;
  final double size;
  final void Function()? onPressed;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final padding = size * 0.2;
    return SizedBox(
        width: size,
        height: size,
        child: IconButton(
          padding: EdgeInsets.all(padding),
          onPressed: onPressed,
          icon: iconWidgetBuilder(size - 2 * padding),
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor,
            disabledBackgroundColor: disabledBackgroundColor,
          ),
        ),
    );
  }
}