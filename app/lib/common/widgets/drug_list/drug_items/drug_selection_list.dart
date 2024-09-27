import '../../../module.dart';
import 'utils.dart';

class DrugItemsBuildParams {
  DrugItemsBuildParams({required this.isEditable, required this.setActivity});

  final bool isEditable;
  final SetDrugActivityFunction setActivity;
}

List<Widget> buildDrugSelectionList(
  BuildContext context,
  List<Drug> drugs,
  {
    DrugItemsBuildParams? buildParams,
    required bool showDrugInteractionIndicator,
    required String keyPrefix,
  }
) {
  if (buildParams == null) throw Exception();
  return _buildSelectionList(
    context,
    drugs,
    buildParams,
    showDrugInteractionIndicator,
    keyPrefix: keyPrefix,
  );
}

List<SwitchListTile> _buildSelectionList(
  BuildContext context,
  List<Drug> drugs,
  DrugItemsBuildParams buildParams,
  bool showDrugInteractionIndicator,
  { required String keyPrefix }
) {
  return drugs.map(
    (drug) => buildDrugActivitySelection(
      key: Key('${keyPrefix}drug-selection-tile-${drug.name}'),
      context: context,
      drug: drug,
      disabled: !buildParams.isEditable,
      isActive: drug.isActive,
      setActivity: buildParams.setActivity,
      title: formatDrugName(drug, showDrugInteractionIndicator),
      subtitle: (drug.annotations.brandNames.isNotEmpty) ?
        formatBrandNames(context, drug) :
        null,
    )
  ).toList();
}
