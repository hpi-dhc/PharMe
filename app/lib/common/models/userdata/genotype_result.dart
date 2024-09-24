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
    LookupInformation? lookup,
  ) => GenotypeResult(
    gene: labResult.gene,
    variant: labResult.variant,
    phenotype: labResult.phenotype,
    lookupkey: lookup?.lookupkey,
    allelesTested: labResult.allelesTested,
  );

  factory GenotypeResult.missingResult(
    String gene, {
      String? variant,
      String? lookupkey,
    }) {
    return GenotypeResult(
      gene: gene,
      variant: variant,
      phenotype: null,
      lookupkey: lookupkey,
      allelesTested: null,
    );
  }
  
  @override
  @HiveField(0)
  String gene;
  @override
  @HiveField(1)
  String? variant;
  @HiveField(2)
  String? phenotype;
  @HiveField(3)
  String? lookupkey;
  @HiveField(4)
  String? allelesTested;

  GenotypeKey get key => GenotypeKey.fromGenotype(this);

  String get geneDisplayString => key.value;

  String _removeAlleleOrNull(String textWithAllele) =>
    key.allele != null
     ? textWithAllele.removePrefix(key.allele!).trim().capitalize()
     : textWithAllele;
  
  String _displayStringOrMissing(
    BuildContext context,
    String? text, {
      bool removeAllele = false,
  }) {
    final displayString = text ?? context.l10n.general_not_tested;
    return !removeAllele || isGeneUnique(key.gene)
      ? displayString
      :  _removeAlleleOrNull(displayString);
  }

  String variantDisplayString(BuildContext context) =>
    _displayStringOrMissing(context, key.allele);

  String phenotypeDisplayString(BuildContext context) =>
    _displayStringOrMissing(context, phenotype, removeAllele: true);

  String genotypeDisplayString(BuildContext context) =>
    _displayStringOrMissing(context, variant, removeAllele: true);
}
