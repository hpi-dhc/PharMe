import '../../common/module.dart';
import 'tooltip_icon.dart';

class SubHeader extends StatelessWidget {
  const SubHeader(
    this.title, {
    this.tooltip,
  });

  final String title;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title.toUpperCase(),
          style: PharMeTheme.textTheme.bodySmall!.copyWith(letterSpacing: 2),
        ),
        if (tooltip.isNotNullOrBlank) ...[
          SizedBox(width: 8),
          TooltipIcon(tooltip!),
        ]
      ],
    );
  }
}
