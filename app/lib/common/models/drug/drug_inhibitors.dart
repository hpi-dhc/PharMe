// Everything has to match literally. The final value is not a phenotype but
// the CPIC lookupkey value. If a user has multiple of the given drugs active,
// the topmost one will be used, i.e. the inhibitors should go from most to
// least severe.

// structure: gene symbol -> drug name -> overwriting lookupkey

import 'package:collection/collection.dart';

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

String possiblyAdaptedPhenotype(GenotypeResult genotypeResult) {
  final originalPhenotype = genotypeResult.phenotypeDisplayString;
  if (!isInhibited(genotypeResult)) {
    return originalPhenotype;
  }
  final overwrittenLookup = getOverwrittenLookup(genotypeResult.gene);
  if (overwrittenLookup == null) {
    return '$originalPhenotype$drugInteractionIndicator';
  }
  return '$overwritePhenotype$drugInteractionIndicator';
}

bool isInhibited(
    GenotypeResult genotypeResult,
    { String? drug }
) {
  final activeInhibitors = activeInhibitorsFor(
    genotypeResult.gene,
    drug: drug,
  );
  final originalPhenotype = genotypeResult.phenotypeDisplayString;
  final phenotypeCanBeInhibited =
    originalPhenotype.toLowerCase() != overwritePhenotype.toLowerCase();
  return activeInhibitors.isNotEmpty && phenotypeCanBeInhibited;
}

List<String> activeInhibitorsFor(String gene, { String? drug }) {
  return UserData.instance.activeDrugNames == null
    ? <String>[]
    : UserData.instance.activeDrugNames!.filter(
        (activeDrug) =>
          inhibitorsFor(gene).contains(activeDrug) &&
          activeDrug != drug
      ).toList();
}

PhenotypeInformation phenotypeInformationFor(
  GenotypeResult genotypeResult,
  BuildContext context,
  {
    String? drug,
    bool thirdPerson = false,
    bool useLongPrefix = false,
  }
) {
  final userSalutation = thirdPerson
    ? context.l10n.drugs_page_inhibitor_third_person_salutation
    : context.l10n.drugs_page_inhibitor_direct_salutation;
  final strongInhibitorTextPrefix = useLongPrefix
    ? context.l10n.strong_inhibitor_long_prefix
    : context.l10n.gene_page_phenotype.toLowerCase();
  final originalPhenotype = genotypeResult.phenotypeDisplayString;
  final activeInhibitors = activeInhibitorsFor(
    genotypeResult.gene,
    drug: drug,
  );
  if (!isInhibited(genotypeResult, drug: drug)) {
    return PhenotypeInformation(phenotype: originalPhenotype);
  }
  final overwrittenLookup = getOverwrittenLookup(
    genotypeResult.gene,
    drug: drug,
  );
  if (overwrittenLookup == null) {
    return PhenotypeInformation(
      phenotype: originalPhenotype,
      adaptionText: context.l10n.drugs_page_moderate_inhibitors(
        userSalutation,
        enumerationWithAnd(
          activeInhibitors,
          context
        ),
      ),
    );
  }
  final originalPhenotypeText = context.l10n.drugs_page_original_phenotype(
    thirdPerson
      ? context.l10n.drugs_page_inhibitor_third_person_salutation_genitive
      : context.l10n.drugs_page_inhibitor_direct_salutation_genitive,
    originalPhenotype,
  );
  return PhenotypeInformation(
    phenotype: overwritePhenotype,
    adaptionText: context.l10n.drugs_page_strong_inhibitors(
        strongInhibitorTextPrefix,
        userSalutation,
        enumerationWithAnd(activeInhibitors, context),
      ),
    overwrittenPhenotypeText: originalPhenotypeText,
  );
}

MapEntry<String, String>? getOverwrittenLookup (
  String gene,
  { String? drug }
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