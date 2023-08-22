import '../../../module.dart';

List<Widget> buildDrugCheckboxList(
  BuildContext context,
  List<Drug> drugs,
  { Map? buildParams }
) {
  if (buildParams == null) throw Exception();
  final onCheckboxChange = buildParams['onCheckboxChange'];
  final checkboxesEnabled = buildParams['checkboxesEnabled'];
  final sortedDrugs = List<Drug>.from(drugs);
  sortedDrugs.sort((drugA, drugB) => drugA.name.compareTo(drugB.name));
  return [
    ...sortedDrugs.map(
      (drug) => CheckboxListTile(
        enabled: checkboxesEnabled,
        value: UserData.instance.activeDrugNames!
          .contains(drug.name),
        onChanged: (value) => onCheckboxChange(drug, value),
        title: Text(drug.name.capitalize()),
        subtitle: (drug.annotations.brandNames.isNotEmpty) ?
          Text('(${drug.annotations.brandNames.join(", ")})') :
          null,
      )
    ).toList(),
  ];
}
