import '../../module.dart';

class GenotypeKey implements Genotype {
  GenotypeKey(this.gene, this.variant);

  factory GenotypeKey.fromGenotype(Genotype genotype) =>
    GenotypeKey(genotype.gene, genotype.variant);

  @override
  String gene;
  
  @override
  String? variant;

  // heavily relies on "non-unique" gene HLA-B, for which the variant is
  // in the format "[allele] [positive/negative]" (which currently is the only)
  // relevant case for "non-unique" genes)
  String? get allele => variant != null
    ? isGeneUnique(gene) ? variant : variant!.split(' ').first
    : null;

  String get value => isGeneUnique(gene)
    ? gene
    : '$gene $allele';

  static String extractGene(String genotypeKey) =>
    genotypeKey.split(' ').first;
  
  static String? maybeExtractVariant(String genotypeKey) {
    final relevantGenotypeParts = genotypeKey.split(' ');
    return relevantGenotypeParts.length > 1
      ? genotypeKey.removePrefix(relevantGenotypeParts.first)
      : null;
  }
}

bool isGeneUnique(String gene) {
  final isDefinedAsNonUnique = definedNonUniqueGenes.contains(gene);
  if (isDefinedAsNonUnique){
    return false;
  }
  final labData = UserData.instance.labData ?? [];
  return labData.where(
    (labData) => labData.gene == gene
  ).length <= 1;
}