import 'package:hive/hive.dart';

import '../../module.dart';

part 'warning_level.g.dart';

@HiveType(typeId: 11)
enum WarningLevel {
  @HiveField(0)
  red,
  @HiveField(1)
  yellow,
  @HiveField(2)
  green,
  @HiveField(3)
  none,
}

extension WarningLevelLabel on WarningLevel {
  String getLabel(BuildContext context) {
    final labelMap = {
      WarningLevel.red.name: context.l10n.warning_level_red,
      WarningLevel.yellow.name: context.l10n.warning_level_yellow,
      WarningLevel.green.name: context.l10n.warning_level_green,
      WarningLevel.none.name: context.l10n.warning_level_missing,
    };
    return labelMap[name]!;
  }
}

extension WarningLevelIcon on WarningLevel {
  static final _iconMap = {
    WarningLevel.red.name: Icons.dangerous_rounded,
    WarningLevel.yellow.name: Icons.warning_rounded,
    WarningLevel.green.name: Icons.check_circle_rounded,
    WarningLevel.none.name: Icons.help_rounded,
  };

  static final _outlinedIconMap = {
    WarningLevel.red.name: Icons.dangerous_outlined,
    WarningLevel.yellow.name: Icons.warning_amber_rounded,
    WarningLevel.green.name: Icons.check_circle_outline_outlined,
    WarningLevel.none.name: Icons.help_outline_rounded,
  };

  IconData get icon => WarningLevelIcon._iconMap[name]!;
  IconData get outlinedIcon => WarningLevelIcon._outlinedIconMap[name]!;
}

extension WarningLevelSeverity on WarningLevel {
  static final _severityMap = {
    WarningLevel.red.name: 2,
    WarningLevel.yellow.name: 1,
    WarningLevel.green.name: 0,
    WarningLevel.none.name: 0,
  };
  int get severity => WarningLevelSeverity._severityMap[name]!;
}

extension WarningLevelColor on WarningLevel {
  static final _colorMap = {
    WarningLevel.red.name: Color(0xffffafaf),
    WarningLevel.yellow.name: Color(0xffffebcc),
    WarningLevel.green.name: Color(0xffcfe8cf),
    WarningLevel.none.name: Color(0xffcfe8cf),
  };

  Color get color => WarningLevelColor._colorMap[name]!;
  Color get textColor => darkenColor(color, 0.4);
}

extension WarningLevelDescription on WarningLevel {
  TextSpan getDescription(String text) => TextSpan(
    children: [
      WidgetSpan(
        child: Icon(
          icon,
          color: textColor,
          size: PharMeTheme.textTheme.bodyMedium!.fontSize,
        ),
      ),
      WidgetSpan(
        child: SizedBox(width: PharMeTheme.smallSpace * 0.4),
      ),
      TextSpan(
        text: text,
        style: PharMeTheme.textTheme.bodyMedium!.copyWith(color: textColor)
      ),
    ],
  );
}

extension WarningLevelLegend on List<WarningLevel> {
  TextSpan buildLegend({
    required String? Function(WarningLevel) getText,
    InlineSpan? separator,
  }) {
    var content = <InlineSpan>[];
    for (final (index, warningLevel) in indexed) {
      final text = getText(warningLevel);
      if (text.isNullOrEmpty) continue;
      final warningLevelIndicator = warningLevel.getDescription(text!);
      final isLastItem = index == WarningLevel.values.length - 1;
      content = isLastItem
        ? [ ...content, warningLevelIndicator ]
        : [
            ...content,
            warningLevelIndicator,
            separator ?? WidgetSpan(
              child: SizedBox(width: PharMeTheme.smallSpace * 0.8),
            ),
          ];
    }
    return TextSpan(
      style: PharMeTheme.textTheme.bodyMedium,
      children: content,
    );
  }

  TextSpan getTextLegend(BuildContext context) => buildLegend(
    getText: (warningLevel) => warningLevel.getLabel(context),
    separator: TextSpan(text: ', '),
  );
}
