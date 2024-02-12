import '../../module.dart';

class GenotypeKey implements Genotype {
  GenotypeKey(this.gene, this.variant);

  factory GenotypeKey.fromGenotype(Genotype genotype) =>
    GenotypeKey(genotype.gene, genotype.variant);

  @override
  String gene;
  
  @override
  String variant;

  String get value {
    final geneData = UserData.instance.labData!.where(
      (labData) => labData.gene == gene
    );
    if (geneData.length > 1) {
      return '$gene ${variant.split(' ').first}';
    }
    return gene;
  }

  static String extractGene(String genotypeKey) =>
    genotypeKey.split(' ').first;
}