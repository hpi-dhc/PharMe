import 'package:collection/collection.dart';

import '../module.dart';

final _drugInhibitorsPerGene = {
  for (final gene in inhibitableGenes) gene: [
    ...?strongDrugInhibitors[gene]?.keys,
    ...?moderateDrugInhibitors[gene]?.keys,
  ]
};

List<String> _inhibitorsFor(String gene) {
  return _drugInhibitorsPerGene[gene] ?? [];
}

bool _isInhibitorOfType(
  String drugName,
  Map<String, Map<String, dynamic>> inhibitorDefinition
) {
  final influencingDrugs = inhibitorDefinition.keys.flatMap(
    (gene) => inhibitorDefinition[gene]!.keys);
  return influencingDrugs.contains(drugName);
}

bool isModerateInhibitor(String drugName) {
  return _isInhibitorOfType(drugName, moderateDrugInhibitors);
}

List<String> activeInhibitorsFor(String gene, { required String? drug }) {
  return UserData.instance.activeDrugNames == null
    ? <String>[]
    : UserData.instance.activeDrugNames!.filter(
        (activeDrug) =>
          _inhibitorsFor(gene).contains(activeDrug) &&
          activeDrug != drug
      ).toList();
}

bool isInhibitor(String drugName) {
  var drugIsInhibitor = false;
  for (final gene in _drugInhibitorsPerGene.keys) {
    final influencingDrugs = _drugInhibitorsPerGene[gene];
    // WARNING: this does not work for non-unique genes, such as HLA-B
    final originalLookup = UserData.lookupFor(
      gene,
      drug: drugName,
      useOverwrite: false,
    );
    if (influencingDrugs!.contains(drugName) && originalLookup != '0.0') {
      drugIsInhibitor = true;
      break;
    }
  }
  return drugIsInhibitor;
}

bool isInhibited(
    GenotypeResult genotypeResult,
    { required String? drug }
) {
  final activeInhibitors = activeInhibitorsFor(
    genotypeResult.gene,
    drug: drug,
  );
  final originalPhenotype = genotypeResult.phenotype;
  final phenotypeCanBeInhibited =
    originalPhenotype?.toLowerCase() != overwritePhenotype.toLowerCase();
  return activeInhibitors.isNotEmpty && phenotypeCanBeInhibited;
}

List<String> inhibitedGenes(Drug drug) {
  return _drugInhibitorsPerGene.keys.filter(
    (gene) => _drugInhibitorsPerGene[gene]!.contains(drug.name)
  ).toList();
}

MapEntry<String, String>? getOverwrittenLookup (
  String gene,
  { required String? drug }
) {
  final inhibitors = strongDrugInhibitors[gene];
  if (inhibitors == null) return null;
  final lookup = inhibitors.entries.firstWhereOrNull((entry) {
    final isActiveInhibitor =
      UserData.instance.activeDrugNames?.contains(entry.key) ?? false;
    final wouldInhibitItself = drug == entry.key;
    return isActiveInhibitor && !wouldInhibitItself;
  });
  if (lookup == null) return null;
  return lookup;
}

String possiblyAdaptedPhenotype(
  BuildContext context,
  GenotypeResult genotypeResult,
  { required String? drug }
) {
  final originalPhenotype = genotypeResult.phenotypeDisplayString(context);
  if (!isInhibited(genotypeResult, drug: drug)) {
    return originalPhenotype;
  }
  final overwrittenLookup = getOverwrittenLookup(
    genotypeResult.gene,
    drug: drug,
  );
  if (overwrittenLookup == null) {
    return '$originalPhenotype$drugInteractionIndicator';
  }
  return '$overwritePhenotype$drugInteractionIndicator';
}
