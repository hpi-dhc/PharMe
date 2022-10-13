import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'warning_level.g.dart';

@HiveType(typeId: 14)
enum WarningLevel {
  @HiveField(0)
  danger,
  @HiveField(1)
  warning,
  @HiveField(2)
  ok
}

extension WarningLevelColor on WarningLevel {
  static final _colorMap = {
    WarningLevel.danger.name: Color(0xFFFFAFAF),
    WarningLevel.warning.name: Color(0xFFFFEBCC),
    WarningLevel.ok.name: Color(0xFFCFE8CF),
  };

  Color get color => WarningLevelColor._colorMap[name]!;
}

extension WarningLevelIcon on WarningLevel {
  static final _iconMap = {
    WarningLevel.danger.name: Icons.dangerous_rounded,
    WarningLevel.warning.name: Icons.warning_rounded,
    WarningLevel.ok.name: Icons.check_circle_rounded,
  };

  IconData get icon => WarningLevelIcon._iconMap[name]!;
}
