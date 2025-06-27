import '../../common/module.dart';


class SourceCard extends StatelessWidget {
  const SourceCard({
    required this.name,
    required this.description,
    required this.onTap,
  });

  final String name;
  final String description;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(colors: [
            PharMeTheme.primaryColor.withValues(alpha: .8),
            PharMeTheme.secondaryColor.withValues(alpha: .8),
          ]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
              flex: 3,
              child: AutoSizeText(
                name,
                style: PharMeTheme.textTheme.bodyMedium!
                    .copyWith(color: PharMeTheme.surfaceColor),
                maxLines: 1,
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              flex: 10,
              child: Text(
                description,
                style: PharMeTheme.textTheme.bodySmall!
                    .copyWith(color: PharMeTheme.surfaceColor),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
