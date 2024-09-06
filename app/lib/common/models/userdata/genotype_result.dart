import 'package:collection/collection.dart';
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
    LabResult labResult,
    LookupInformation lookup,
  ) => GenotypeResult(
    gene: labResult.gene,
    variant: labResult.variant,
    phenotype: labResult.phenotype,
    lookupkey: lookup.lookupkey,
    allelesTested: labResult.allelesTested,
  );

  factory GenotypeResult.missingResult(String gene, BuildContext context) {
    final potentialLabResultWithoutLookups =
      UserData.instance.labData?.firstWhereOrNull(
        (labResult) => labResult.gene == gene
      );
    return GenotypeResult(
      gene: gene,
      variant: potentialLabResultWithoutLookups?.variant
        ?? context.l10n.general_not_tested,
      phenotype: potentialLabResultWithoutLookups?.phenotype
        ?? context.l10n.general_not_tested,
      lookupkey: context.l10n.general_not_tested,
      allelesTested: potentialLabResultWithoutLookups?.allelesTested
        ?? context.l10n.general_not_tested,
    );
  }
  
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

  GenotypeKey get key => GenotypeKey.fromGenotype(this);

  String get geneDisplayString => key.value;

  String get variantDisplayString => key.allele;

  String _removeAllele(String textWithAllele) =>
    textWithAllele.removePrefix(key.allele).trim().capitalize();

  String get phenotypeDisplayString => key.isGeneUnique
    ? phenotype
    : _removeAllele(phenotype);
  String get genotypeDisplayString => key.isGeneUnique
    ? variant
    : _removeAllele(variant);
}

extension FindGenotypeResultByKey on Map<String, GenotypeResult> {
  bool isMissing(String genotypeKey) => this[genotypeKey] == null;

  GenotypeResult findOrMissing(String genotypeKey, BuildContext context) =>
    isMissing(genotypeKey)
      ? GenotypeResult.missingResult(
          GenotypeKey.extractGene(genotypeKey),
          context,
        )
      : this[genotypeKey]!;
}
