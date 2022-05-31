import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'guideline.g.dart';

@HiveType(typeId: 9)
@JsonSerializable()
class Guideline {
  Guideline({
    required this.id,
    this.implication,
    this.recommendation,
    this.warningLevel,
    this.cpicRecommendation,
    this.cpicImplication,
    this.cpicClassification,
    this.cpicComment,
    required this.genePhenotype,
  });
  factory Guideline.fromJson(dynamic json) => _$GuidelineFromJson(json);

  @HiveField(0)
  int id;

  @HiveField(1)
  String? implication;

  @HiveField(2)
  String? recommendation;

  @HiveField(3)
  String? warningLevel;

  @HiveField(4)
  String? cpicRecommendation;

  @HiveField(5)
  String? cpicImplication;

  @HiveField(6)
  String? cpicClassification;

  @HiveField(7)
  String? cpicComment;

  @HiveField(8)
  GenePhenotype genePhenotype;
}

@HiveType(typeId: 10)
@JsonSerializable()
class GenePhenotype {
  GenePhenotype({
    required this.id,
    required this.phenotype,
    required this.geneSymbol,
  });
  factory GenePhenotype.fromJson(dynamic json) => _$GenePhenotypeFromJson(json);

  @HiveField(0)
  int id;

  @HiveField(1)
  Phenotype phenotype;

  @HiveField(2)
  GeneSymbol geneSymbol;
}

@HiveType(typeId: 11)
@JsonSerializable()
class GeneSymbol {
  GeneSymbol({
    required this.id,
    required this.name,
  });
  factory GeneSymbol.fromJson(dynamic json) => _$GeneSymbolFromJson(json);

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;
}

@HiveType(typeId: 12)
@JsonSerializable()
class Phenotype {
  Phenotype({
    required this.id,
    required this.name,
  });
  factory Phenotype.fromJson(dynamic json) => _$PhenotypeFromJson(json);

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;
}
