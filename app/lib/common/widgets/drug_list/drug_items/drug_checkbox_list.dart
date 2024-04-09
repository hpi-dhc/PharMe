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
  final activeDrugs = drugs.filter((drug) => drug.isActive).toList();
  final activeDrugsList = activeDrugs.isEmpty
      ? [Padding(
          padding: EdgeInsets.all(PharMeTheme.mediumSpace),
          child: Text(
            context.l10n.drug_selection_no_active_drugs,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        )]
      : _buildCheckboxList(
          context,
          activeDrugs,
          buildParams,
          showDrugInteractionIndicator,
          keyPrefix: 'active',
        );
  final allDrugsList = _buildCheckboxList(
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

List<CheckboxListTileWrapper> _buildCheckboxList(
  BuildContext context,
  List<Drug> drugs,
  Map buildParams,
  bool showDrugInteractionIndicator,
  { required String keyPrefix }
) {
  final onCheckboxChange = buildParams['onCheckboxChange'];
  final checkboxesEnabled = buildParams['checkboxesEnabled'];
  return drugs.map(
    (drug) => CheckboxListTileWrapper(
      key: Key('drug-checkbox-tile-${drug.name}-$keyPrefix'),
      isEnabled: checkboxesEnabled,
      isChecked: drug.isActive,
      onChanged: (value) => onCheckboxChange(drug, value),
      title: formatDrugName(drug, showDrugInteractionIndicator),
      subtitle: (drug.annotations.brandNames.isNotEmpty) ?
        formatBrandNames(context, drug) :
        null,
    )
  ).toList();
}
