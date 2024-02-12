import 'package:hive/hive.dart';

import '../../module.dart';

part 'genotype_result.g.dart';

@HiveType(typeId: 2)
class GenotypeResult implements Genotype {
  GenotypeResult({
    required this.gene,
    required this.variant,
    required this.phenotype,
    required this.lookupkey,
    required this.allelesTested,
  });

  factory GenotypeResult.fromGenotypeData(
    GeneResult labResult,
    LookupInformation lookup,
  ) => GenotypeResult(
    gene: labResult.gene,
    variant: labResult.variant,
    phenotype: labResult.phenotype,
    lookupkey: lookup.lookupkey,
    allelesTested: labResult.allelesTested,
  );

  factory GenotypeResult.missingResult(String gene, BuildContext context) =>
    GenotypeResult(
      gene: gene,
      variant: context.l10n.general_not_tested,
      phenotype: context.l10n.general_not_tested,
      lookupkey: context.l10n.general_not_tested,
      allelesTested: context.l10n.general_not_tested,
    );
  
  @override
  @HiveField(0)
  String gene;
  @override
  @HiveField(1)
  String variant;
  @HiveField(2)
  String phenotype;
  @HiveField(3)
  String lookupkey;
  @HiveField(4)
  String allelesTested;

  String get key => GenotypeKey.fromGenotype(this).value;
}

extension FindGenotypeResultByKey on Map<String, GenotypeResult> {
  GenotypeResult findOrMissing(String genotypeKey, BuildContext context) =>
    this[genotypeKey] ?? GenotypeResult.missingResult(
      GenotypeKey.extractGene(genotypeKey),
      context,
    );
}