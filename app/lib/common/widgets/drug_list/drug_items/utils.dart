import '../../../module.dart';

String formatBrandNames(BuildContext context, Drug drug) =>
  '${context.l10n.drug_item_brand_names}: '
  '${drug.annotations.brandNames.join(", ")}';

String formatDrugName(
  Drug drug,
  // ignore: avoid_positional_boolean_parameters
  bool showDrugInteractionIndicator,
) {
  var drugName = drug.name.capitalize();
  if (showDrugInteractionIndicator && isInhibitor(drug.name)) {
    drugName = '$drugName$drugInteractionIndicator';
  }
  return drugName;
}