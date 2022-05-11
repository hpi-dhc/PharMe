import '../models/medication.dart';
import '../models/userdata.dart';

// removes the guidelines that are not passing to the user
MedicationWithGuidelines extractRelevantGuidelineFromMedication(
  MedicationWithGuidelines medication,
) {
  final matchingGuidelines = medication.guidelines.where((guideline) {
    final foundEntry =
        UserData.instance.lookups![guideline.genePhenotype.geneSymbol.name];
    return foundEntry != null &&
        foundEntry == guideline.genePhenotype.phenotype.name;
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
