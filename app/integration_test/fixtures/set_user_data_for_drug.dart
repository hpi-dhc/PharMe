import 'package:app/common/models/drug/drug.dart';
import 'package:app/common/models/userdata/genotype_result.dart';
import 'package:app/common/models/userdata/lab_result.dart';
import 'package:app/common/models/userdata/userdata.dart';

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

void setUserDataForDrug(Drug drug) {
  UserData.instance.labData = UserData.instance.labData ?? [];
  UserData.instance.genotypeResults = UserData.instance.genotypeResults ?? {};
  final userDataConfig = _UserDataConfig(
    gene: drug.guidelines.first.lookupkey.keys.first,
    lookupkey:
      drug.guidelines.first.lookupkey.values.first.first,
  );
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