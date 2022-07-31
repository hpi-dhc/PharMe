import 'package:flutter/material.dart';

enum WarningLevel { danger, warning, ok }

final recommendationColorMap = {
  WarningLevel.danger.name: Color(0xFFFFAFAF),
  WarningLevel.ok.name: Color(0xFF00FF00),
  WarningLevel.warning.name: Color(0xFFFFEBCC),
};

final recommendationIconMap = {
  WarningLevel.danger.name: Icons.dangerous_rounded,
  WarningLevel.ok.name: Icons.check_circle_rounded,
  WarningLevel.warning.name: Icons.warning_rounded,
};
