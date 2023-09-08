import '../module.dart';

WarningLevel getWarningLevel(Guideline? guideline) =>
  guideline?.annotations.warningLevel ?? WarningLevel.none;