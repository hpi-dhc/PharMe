// Everything has to match literally. The final value is not a phenotype but
// the CPIC lookupkey value. If a user has multiple of the given drugs active,
// the topmost one will be used, i.e. the inhibitors should go from most to
// least severe.

// structure: gene symbol -> drug name -> overwriting lookupkey

import '../../module.dart';

// Inhibit phenotype for gene by overwriting with poor metabolizer
const Map<String, Map<String, String>> strongDrugInhibitors = {
  'CYP2D6': {
    'bupropion': '0.0',
    'fluoxetine': '0.0',
    'paroxetine': '0.0',
    'quinidine': '0.0',
    'terbinafine': '0.0',
  },
};

// Inhibit phenotype for gene by adapting the activity score by a defined
// factor; not implement yet, currently only showing the warning (see
// https://github.com/hpi-dhc/PharMe/issues/667)
const Map<String, Map<String, double>> moderateDrugInhibitors = {
  'CYP2D6': {
    'abiraterone': 0.5,
    'cinacalcet': 0.5,
    'duloxetine': 0.5,
    'lorcaserin': 0.5,
    'mirabegron': 0.5,
  },
};

final inhibitableGenes = List<String>.from(<String>{
  ...strongDrugInhibitors.keys,
  ...moderateDrugInhibitors.keys,
});

final _drugInhibitorsPerGene = {
  for (final gene in inhibitableGenes) gene: [
    ...?strongDrugInhibitors[gene]?.keys,
    ...?moderateDrugInhibitors[gene]?.keys,
  ]
};

bool _isInhibitorOfType(
  String drugName,
  Map<String, Map<String, dynamic>> inhibitorDefinition
) {
  final influencingDrugs = inhibitorDefinition.keys.flatMap(
    (gene) => inhibitorDefinition[gene]!.keys);
  return influencingDrugs.contains(drugName);
}

bool isStrongInhibitor(String drugName) {
  return _isInhibitorOfType(drugName, strongDrugInhibitors);
}

bool isModerateInhibitor(String drugName) {
  return _isInhibitorOfType(drugName, moderateDrugInhibitors);
}

bool isInhibitor(String drugName) {
  var drugIsInhibitor = false;
  for (final gene in _drugInhibitorsPerGene.keys) {
    final influencingDrugs = _drugInhibitorsPerGene[gene];
    final originalLookup = UserData.lookupFor(gene, drug: drugName, useOverwrite: false);
    if (influencingDrugs!.contains(drugName) && originalLookup != '0.0') {
      drugIsInhibitor = true;
      break;
    }
  }
  return drugIsInhibitor;
}

List<String> inhibitedGenes(Drug drug) {
  return _drugInhibitorsPerGene.keys.filter(
    (gene) => _drugInhibitorsPerGene[gene]!.contains(drug.name)
  ).toList();
}

List<String> inhibitorsFor(String gene) {
  return _drugInhibitorsPerGene[gene] ?? [];
}

bool canBeInhibited(GenotypeResult genotypeResult) {
  return inhibitableGenes.contains(genotypeResult.gene) &&
    genotypeResult.lookupkey != '0.0';
}
