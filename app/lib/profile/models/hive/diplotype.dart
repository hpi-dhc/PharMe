import 'package:hive/hive.dart';

part 'diplotype.g.dart';

@HiveType(typeId: 1)
class Diplotype {
  Diplotype(
      {required this.gene,
      required this.resultType,
      required this.genotype,
      required this.phenotype,
      required this.allelesTested});

  factory Diplotype.fromJson(Map<String, dynamic> json) => Diplotype(
        gene: json['Gene'] as String,
        resultType: json['ResultType'] as String,
        genotype: json['Genotype'] as String,
        phenotype: json['Phenotype'] as String,
        allelesTested: json['AllelesTested'] as String,
      );

  @HiveField(0)
  String gene;

  @HiveField(1)
  String resultType;

  @HiveField(2)
  String genotype;

  @HiveField(3)
  String phenotype;

  @HiveField(4)
  String allelesTested;

  @override
  String toString() {
    return gene;
  }
}
