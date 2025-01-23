import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../module.dart';

enum ListPageInclusionDescriptionType {
  medications,
  genes,
}

class ListPageInclusionDescription extends StatelessWidget {
  const ListPageInclusionDescription({
    super.key,
    this.text,
    this.customPadding,
    required this.type,
  });

  final String? text;
  final ListPageInclusionDescriptionType type;
  final EdgeInsets? customPadding;

  @override
  Widget build(BuildContext context) {
    final inclusionText = context.l10n.included_content_disclaimer_text(
      type == ListPageInclusionDescriptionType.medications
        ? context.l10n.included_content_medications
        : context.l10n.included_content_genes
    );
    return PageDescription(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (text != null) Text(text!),
          if (text != null) SizedBox(height: PharMeTheme.smallToMediumSpace),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: PharMeTheme.smallSpace * 1.5,
                  right: PharMeTheme.smallSpace * 1.5,
                  top: PharMeTheme.smallSpace * 0.5,
                  bottom: PharMeTheme.smallSpace,
                ),
                child: IncludedContentIcon(type: type),
              ),
              Expanded(
                child: Text(
                  inclusionText,
                  style: TextStyle(color: PharMeTheme.iconColor),
                ),
              ),
            ],
          ),
        ],
      ),
      customPadding: customPadding,
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

  final ListPageInclusionDescriptionType type;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final icon = type == ListPageInclusionDescriptionType.medications
      ? medicationsIcon
      : genesIcon;
    final totalSize = size ?? PharMeTheme.mediumToLargeSpace * 1.5;
    final iconSize = totalSize * 0.9;
    final checkIconBackgroundSize = totalSize * 0.5;
    final checkIconSize = checkIconBackgroundSize * 0.8;
    final rightShift = type == ListPageInclusionDescriptionType.medications
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