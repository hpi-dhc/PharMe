import '../../../module.dart';
import 'utils.dart';

List<Widget> buildDrugCheckboxList(
  BuildContext context,
  List<Drug> drugs,
  {
    Map? buildParams,
    bool showDrugInteractionIndicator = false,
  }
) {
  if (buildParams == null) throw Exception();
  final activeDrugs = drugs.filter((drug) => drug.isActive()).toList();
  final activeDrugsList = activeDrugs.isEmpty
      ? [Padding(
          padding: EdgeInsets.all(PharMeTheme.mediumSpace),
          child: Text(
            context.l10n.drug_selection_no_active_drugs,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        )]
      : _buildCheckboxList(
          activeDrugs,
          buildParams,
          showDrugInteractionIndicator,
          keyPrefix: 'active',
        );
  final allDrugsList = _buildCheckboxList(
    drugs,
    buildParams,
    showDrugInteractionIndicator,
    keyPrefix: 'all',
  );
  return [
    SubheaderDivider(context.l10n.drug_selection_subheader_active_drugs),
    ...activeDrugsList,
    SubheaderDivider(context.l10n.drug_selection_subheader_all_drugs),
    ...allDrugsList,
  ];
}

List<CheckboxListTile> _buildCheckboxList(
  List<Drug> drugs,
  Map buildParams,
  bool showDrugInteractionIndicator,
  { required String keyPrefix }
) {
  final onCheckboxChange = buildParams['onCheckboxChange'];
  final checkboxesEnabled = buildParams['checkboxesEnabled'];
  return drugs.map(
    (drug) => CheckboxListTile(
      key: Key('drug-checkbox-tile-${drug.name}-$keyPrefix'),
      enabled: checkboxesEnabled,
      value: drug.isActive(),
      onChanged: (value) => onCheckboxChange(drug, value),
      title: Text(formatDrugName(drug, showDrugInteractionIndicator)),
      subtitle: (drug.annotations.brandNames.isNotEmpty) ?
        Text('(${drug.annotations.brandNames.join(", ")})') :
        null,
    )
  ).toList();
}
