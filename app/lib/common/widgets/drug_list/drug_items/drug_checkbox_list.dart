import '../../../module.dart';

bool isDrugSelected(Drug drug) {
  return UserData.instance.activeDrugNames!.contains(drug.name);
}

List<Widget> buildDrugCheckboxList(
  BuildContext context,
  List<Drug> drugs,
  { Map? buildParams }
) {
  if (buildParams == null) throw Exception();
  final onCheckboxChange = buildParams['onCheckboxChange'];
  final checkboxesEnabled = buildParams['checkboxesEnabled'];
  final sortedDrugs = List<Drug>.from(drugs);
  sortedDrugs.sort((drugA, drugB) {
    final drugASelected = isDrugSelected(drugA);
    final drugBSelected = isDrugSelected(drugB);
    if (drugASelected == drugBSelected) return drugA.name.compareTo(drugB.name);
    return drugASelected ? -1 : 1;
  });
  return [
    ...sortedDrugs.map(
      (drug) => CheckboxListTile(
        enabled: checkboxesEnabled,
        value: isDrugSelected(drug),
        onChanged: (value) => onCheckboxChange(drug, value),
        title: Text(drug.name.capitalize()),
        subtitle: (drug.annotations.brandNames.isNotEmpty) ?
          Text('(${drug.annotations.brandNames.join(", ")})') :
          null,
      )
    ).toList(),
  ];
}
