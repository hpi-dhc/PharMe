import 'package:dartx/dartx.dart';

import '../models/module.dart';

// removes the guidelines that are not passing to the user
MedicationWithGuidelines filterUserGuidelines(
  MedicationWithGuidelines medication,
) {
  final matchingGuidelines = medication.guidelines.where((guideline) {
    final phenotype = guideline.phenotype;
    final foundEntry =
        UserData.instance.lookups![guideline.phenotype.geneSymbol.name];
    return foundEntry.isNotNullOrBlank &&
        foundEntry == phenotype.geneResult.name;
  });
  return MedicationWithGuidelines(
    id: medication.id,
    name: medication.name,
    description: medication.description,
    pharmgkbId: medication.pharmgkbId,
    rxcui: medication.rxcui,
    synonyms: medication.synonyms,
    drugclass: medication.drugclass,
    indication: medication.indication,
    guidelines: matchingGuidelines.toList(),
  );
}
