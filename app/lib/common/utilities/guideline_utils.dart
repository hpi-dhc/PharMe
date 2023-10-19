import '../models/drug/cached_drugs.dart';
import '../module.dart';

List<String> getGuidelineGenes() {
  final genes = <String>{};
  for (final drug in CachedDrugs.instance.drugs!) {
    for (final guideline in drug.guidelines) {
      guideline.lookupkey.keys.forEach(genes.add);
    }
  }
  return List.from(genes);
}

WarningLevel getWarningLevel(Guideline? guideline) =>
  guideline?.annotations.warningLevel ?? WarningLevel.none;