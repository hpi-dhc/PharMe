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

extension WarningLevelIcon on WarningLevel {
  static final _iconMap = {
    WarningLevel.danger.name: Icons.dangerous_rounded,
    WarningLevel.warning.name: Icons.warning_rounded,
    WarningLevel.ok.name: Icons.check_circle_rounded,
  };

  IconData get icon => WarningLevelIcon._iconMap[name]!;
}

extension WarningLevelSeverity on WarningLevel {
  static final _severityMap = {
    WarningLevel.danger.name: 2,
    WarningLevel.warning.name: 1,
    WarningLevel.ok.name: 0
  };
  int get severity => WarningLevelSeverity._severityMap[name]!;
}