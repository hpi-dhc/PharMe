import 'package:dartx/dartx.dart';

import '../models/module.dart';

// removes the guidelines that are not passing to the user
MedicationWithGuidelines filterUserGuidelines(
  MedicationWithGuidelines medication,
) {
  final matchingGuidelines = medication.guidelines.where((guideline) {
    final genePhenotype = guideline.genePhenotype;
    final foundEntry =
        UserData.instance.lookups![guideline.genePhenotype.geneSymbol.name];
    return foundEntry.isNotNullOrBlank &&
        foundEntry == genePhenotype.phenotype.name;
  });
  return MedicationWithGuidelines(
    medication.id,
    medication.name,
    medication.description,
    medication.pharmgkbId,
    medication.rxcui,
    medication.synonyms,
    medication.drugclass,
    medication.indication,
    matchingGuidelines.toList(),
  );
}
