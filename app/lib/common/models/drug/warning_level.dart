import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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

extension WarningLevelIcon on WarningLevel {
  static final _iconMap = {
    WarningLevel.red.name: Icons.dangerous_rounded,
    WarningLevel.yellow.name: Icons.warning_rounded,
    WarningLevel.green.name: Icons.check_circle_rounded,
  };

  IconData get icon => WarningLevelIcon._iconMap[name]!;
}

extension WarningLevelSeverity on WarningLevel {
  static final _severityMap = {
    WarningLevel.red.name: 2,
    WarningLevel.yellow.name: 1,
    WarningLevel.green.name: 0,
    WarningLevel.none.name: -1,
  };
  int get severity => WarningLevelSeverity._severityMap[name]!;
}
