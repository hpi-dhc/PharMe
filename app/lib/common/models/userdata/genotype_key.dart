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
    final geneResults = UserData.instance.geneResults!.where(
    (geneResult) => geneResult.gene == gene
    );
    if (geneResults.length > 1) {
      return '$gene ${variant.split(' ').first}';
    }
    return gene;
  }

  static String extractGene(String genotypeKey) =>
    genotypeKey.split(' ').first;
}