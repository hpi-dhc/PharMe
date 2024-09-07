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
  }
) {
  if (buildParams == null) throw Exception();
  final activeDrugs = drugs.filter((drug) => drug.isActive).toList();
  final activeDrugsList = activeDrugs.isEmpty
      ? [Padding(
          padding: EdgeInsets.all(PharMeTheme.mediumSpace),
          child: Text(
            context.l10n.drug_selection_no_active_drugs,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        )]
      : _buildSelectionList(
          context,
          activeDrugs,
          buildParams,
          showDrugInteractionIndicator,
          keyPrefix: 'active',
        );
  final allDrugsList = _buildSelectionList(
    context,
    drugs,
    buildParams,
    showDrugInteractionIndicator,
    keyPrefix: 'all',
  );
  return [
    SubheaderDivider(
      text: context.l10n.drug_selection_subheader_active_drugs,
      key: Key('header-active'),
      useLine: false,
    ),
    ...activeDrugsList,
    SubheaderDivider(
      text: context.l10n.drug_selection_subheader_all_drugs,
      key: Key('header-all'),
      useLine: false,
    ),
    ...allDrugsList,
  ];
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
      key: Key('drug-selection-tile-${drug.name}-$keyPrefix'),
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
