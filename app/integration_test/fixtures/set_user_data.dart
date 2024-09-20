import 'package:app/common/module.dart';

class _UserDataConfig {
  _UserDataConfig({
    required this.gene,
    required this.lookupkey,
  });
  final String gene;
  final String lookupkey;
  final String phenotype = 'phenotype does not matter for test';
  final String variant = 'variant does not matter for test';
  final String allelesTested = 'allelesTested does not matter for test';
}

void setUserDataForGuideline(Guideline guideline) {
  UserData.instance.labData = UserData.instance.labData ?? [];
  UserData.instance.genotypeResults = UserData.instance.genotypeResults ?? {};
  for (final gene in guideline.lookupkey.keys) {
    final lookupkeys = guideline.lookupkey[gene]!;
    if (lookupkeys.length != 1) {
      debugPrint(
        'Warning: using only first lookupkey of ${lookupkeys.length} to set '
        'user data',
      );
    }
    var lookupkey = lookupkeys.first;
    if (lookupkey == '*' || lookupkey == '~') {
      lookupkey = 'certainly not handled lookupkey';
    }
    final userDataConfig = _UserDataConfig(
      gene: gene,
      lookupkey: lookupkey,
    );
    // Need to be careful with non-unique genes here; e.g., is we want to use
    // multiple HLA-B variants in the tests, we will need to check for the
    // genotype key (which is in the current setup not possible without the
    // variant)
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
    UserData.instance.genotypeResults![userDataConfig.gene] = GenotypeResult(
      gene: userDataConfig.gene,
      phenotype: userDataConfig.phenotype,
      variant: userDataConfig.variant,
      allelesTested: userDataConfig.variant,
      lookupkey: userDataConfig.lookupkey,
    );
  }
}
