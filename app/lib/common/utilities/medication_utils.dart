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
