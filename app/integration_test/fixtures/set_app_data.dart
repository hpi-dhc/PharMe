import 'package:app/common/module.dart';

class _UserDataConfig {
  _UserDataConfig({
    required this.gene,
    required this.lookupkey,
  });
  final String gene;
  final String lookupkey;
  String get phenotype => lookupkey;
  String get variant => lookupkey;
  final String allelesTested = 'allelesTested does not matter for test';
}

void setGenotypeResult(GenotypeResult genotypeResult) {
  UserData.instance.genotypeResults = UserData.instance.genotypeResults ?? {};
  UserData.instance.genotypeResults![genotypeResult.key.value] = genotypeResult;
}

void setUserDataForGuideline(
  Guideline guideline, {
  List<String>? explicitNoResult,
  Map<String, String>? explicitLookups,
  bool missingLookup = false,
}) {
  UserData.instance.labData = UserData.instance.labData ?? [];
  for (final gene in guideline.lookupkey.keys) {
    final lookupkeys = guideline.lookupkey[gene]!;
    if (lookupkeys.length != 1) {
      debugPrint(
        'Warning: using only first lookupkey of ${lookupkeys.length} to set '
        'user data',
      );
    }
    var lookupkey = lookupkeys.first;
    if (
      lookupkey == SpecialLookup.any.value ||
      lookupkey == SpecialLookup.anyNotHandled.value
    ) {
      lookupkey = 'certainly not handled lookupkey';
    }
    if (explicitLookups?.keys.contains(gene) ?? false) {
      lookupkey = explicitLookups![gene]!;
    }
    final userDataConfig = _UserDataConfig(
      gene: gene,
      lookupkey: lookupkey,
    );
    // Need to be careful with non-unique genes here; e.g., is we want to use
    // multiple HLA-B variants in the tests or overwrite a specific HLA-B
    // variant, we will need to check for the genotype key (which is in the
    // current setup not possible without the proper variant)
    final resultIsMissing = lookupkey == SpecialLookup.noResult.value ||
      (explicitNoResult?.contains(gene) ?? false);
    if (!resultIsMissing) {
      UserData.instance.labData = UserData.instance.labData!.filter(
        (labResult) => labResult.gene != gene
      ).toList();
      UserData.instance.labData!.add(
        LabResult(
          gene: userDataConfig.gene,
          variant: userDataConfig.variant,
          phenotype: userDataConfig.phenotype,
          allelesTested: userDataConfig.allelesTested,
        ),
      );
      setGenotypeResult(GenotypeResult(
        gene: userDataConfig.gene,
        phenotype: userDataConfig.phenotype,
        variant: userDataConfig.variant,
        allelesTested: userDataConfig.variant,
        lookupkey: missingLookup ? null : userDataConfig.lookupkey,
      ));
    }
  }
}

void addDrugToDrugsWithGuidelines(Drug drug) {
  DrugsWithGuidelines.instance.drugs = DrugsWithGuidelines.instance.drugs ?? [];
  final drugIsPresent = DrugsWithGuidelines.instance.drugs!.any(
    (presentDrug) => presentDrug.name == drug.name,
  );
  if (drugIsPresent) return;
  DrugsWithGuidelines.instance.drugs!.add(drug);
}

void setAppData({
  required Drug drug,
  Guideline? guideline,
  List<String>? explicitNoResult,
  Map<String, String>? explicitLookups,
  bool missingLookup = false,
}) {
  addDrugToDrugsWithGuidelines(drug);
  for (final noResultGenotypeResult in initializeGenotypeResultKeys().values) {
    if (drug.guidelineGenotypes.contains(noResultGenotypeResult.key.value)) {
      setGenotypeResult(noResultGenotypeResult);
    }
  }
  if (guideline != null) {
    setUserDataForGuideline(
      guideline,
      explicitNoResult: explicitNoResult,
      explicitLookups: explicitLookups,
      missingLookup: missingLookup,
    );
  }
}
