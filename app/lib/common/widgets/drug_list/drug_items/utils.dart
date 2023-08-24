import '../../../module.dart';

String formatDrugName(
  Drug drug,
  // ignore: avoid_positional_boolean_parameters
  bool showDrugInteractionIndicator,
) {
  var drugName = drug.name.capitalize();
  if (showDrugInteractionIndicator && isInhibitor(drug)) {
    drugName = '$drugName$drugInteractionIndicator';
  }
  return drugName;
}