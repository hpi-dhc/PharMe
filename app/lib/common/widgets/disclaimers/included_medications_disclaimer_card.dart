import '../../module.dart';

class IncludedMedicationsDisclaimerCard extends StatelessWidget {
  const IncludedMedicationsDisclaimerCard({super.key, this.elevation});

  final double? elevation;

  @override
  Widget build(BuildContext context) => DisclaimerCard(
    iconWidget: IncludedContentIcon(
      type: ListInclusionDescriptionType.medications,
      color: PharMeTheme.onSurfaceText,
      size: defaultDisclaimerCardIconSize,
    ),
    iconPadding: EdgeInsets.all(PharMeTheme.smallSpace * 0.3),
    textWidget: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: context.l10n.included_content_disclaimer_text(
              context.l10n.included_content_medications,
              context.l10n.included_content_inclusion_medications,
            ),
          ),
          TextSpan(text: '\n\n'),
          TextSpan(
            text: context.l10n.included_content_addition,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ]
      ),
    ),
    elevation: elevation,
  );
}