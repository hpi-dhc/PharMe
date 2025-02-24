import '../../../module.dart';

class IncludedContentDisclaimerCard extends StatelessWidget {
  const IncludedContentDisclaimerCard({super.key, required this.type});

  final ListInclusionDescriptionType type;

  @override
  Widget build(BuildContext context) {
    final text = type == ListInclusionDescriptionType.genes
      ? TextSpan(
          text: context.l10n.included_content_disclaimer_text(
            context.l10n.included_content_genes,
            context.l10n.included_content_inclusion_genes,
          ),
        )
      : TextSpan(
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
        );
    return DisclaimerCard(
      iconWidget: IncludedContentIcon(
        type: type,
        color: PharMeTheme.onSurfaceText,
        size: defaultDisclaimerCardIconSize,
      ),
      iconPadding: EdgeInsets.all(PharMeTheme.smallSpace * 0.3),
      textWidget: Text.rich(text),
    );
  }
}