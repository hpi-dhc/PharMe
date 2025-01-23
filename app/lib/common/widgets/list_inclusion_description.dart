import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../module.dart';

enum ListInclusionDescriptionType {
  medications,
  genes,
}

class ListInclusionDescription extends StatelessWidget {
  const ListInclusionDescription({
    super.key,
    required this.type,
  });

  factory ListInclusionDescription.forMedications() =>
    ListInclusionDescription(type: ListInclusionDescriptionType.medications);
  factory ListInclusionDescription.forGenes() =>
    ListInclusionDescription(type: ListInclusionDescriptionType.genes);

  final ListInclusionDescriptionType type;

  @override
  Widget build(BuildContext context) {
    final inclusionText = context.l10n.included_content_disclaimer_text(
      type == ListInclusionDescriptionType.medications
        ? context.l10n.included_content_medications
        : context.l10n.included_content_genes
    );
    return DisclaimerRow(
      icon: Padding(
        padding: EdgeInsets.only(
          left: PharMeTheme.smallSpace,
          right: PharMeTheme.smallSpace * 0.5,
        ),
        child: IncludedContentIcon(type: type),
      ),
      text: Text(
        inclusionText,
        style: TextStyle(color: PharMeTheme.iconColor),
      ),
    );
  }
  
}

class IncludedContentIcon extends StatelessWidget {
  const IncludedContentIcon({
    super.key,
    required this.type,
    this.color,
    this.size,
  });

  final ListInclusionDescriptionType type;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final icon = type == ListInclusionDescriptionType.medications
      ? medicationsIcon
      : genesIcon;
    final totalSize = size ?? PharMeTheme.mediumToLargeSpace * 1.5;
    final iconSize = totalSize * 0.9;
    final checkIconBackgroundSize = totalSize * 0.5;
    final checkIconSize = checkIconBackgroundSize * 0.8;
    final rightShift = type == ListInclusionDescriptionType.medications
      ? checkIconBackgroundSize / 2
      : checkIconBackgroundSize / 4;
    return Stack(
      children: [
        SizedBox(
          height: totalSize,
          width: totalSize + rightShift,
        ),
        Icon(
          icon,
          size: iconSize,
          color: color ?? PharMeTheme.buttonColor,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Stack(
            children: [
              Icon(
                FontAwesomeIcons.solidCircle,
                size: checkIconBackgroundSize,
                color: PharMeTheme.surfaceColor,
              ),
              Positioned(
                top: (checkIconBackgroundSize - checkIconSize) / 2,
                left: (checkIconBackgroundSize - checkIconSize) / 2,
                child: Icon(
                  FontAwesomeIcons.solidCircleCheck,
                  size: checkIconSize,
                  color: PharMeTheme.sinaiPurple,
                )),
            ],
          ),
        )
      ],
    );
  }

}