import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../../module.dart';

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
    required this.cpicGuidelineUrl,
    required this.phenotype,
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
  String cpicGuidelineUrl;

  @HiveField(9)
  Phenotype phenotype;

  /// some properties are intentionally omitted, because a difference in them
  /// does not imply that this a completely new guideline
  @override
  bool operator ==(other) {
    return other is Guideline &&
        implication == other.implication &&
        recommendation == other.recommendation &&
        warningLevel == other.warningLevel &&
        cpicRecommendation == other.cpicRecommendation &&
        cpicImplication == other.cpicImplication &&
        cpicClassification == other.cpicClassification &&
        cpicComment == other.cpicComment &&
        cpicGuidelineUrl == other.cpicGuidelineUrl &&
        phenotype == other.phenotype;
  }

  @override
  int get hashCode {
    return hashValues(
      implication,
      recommendation,
      warningLevel,
      cpicRecommendation,
      cpicImplication,
      cpicClassification,
      cpicComment,
      cpicGuidelineUrl,
      phenotype,
    );
  }
}

@HiveType(typeId: 10)
@JsonSerializable()
class Phenotype {
  Phenotype({
    required this.id,
    required this.geneResult,
    required this.geneSymbol,
    this.cpicConsulationText,
  });
  factory Phenotype.fromJson(dynamic json) => _$PhenotypeFromJson(json);

  @HiveField(0)
  int id;

  @HiveField(1)
  GeneResult geneResult;

  @HiveField(2)
  GeneSymbol geneSymbol;

  @HiveField(3)
  String? cpicConsulationText;

  @override
  bool operator ==(other) {
    return other is Phenotype &&
        geneResult.name == other.geneResult.name &&
        geneSymbol.name == other.geneSymbol.name;
  }

  @override
  int get hashCode => hashValues(geneResult.name, geneSymbol.name);
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
class GeneResult {
  GeneResult({
    required this.id,
    required this.name,
  });
  factory GeneResult.fromJson(dynamic json) => _$GeneResultFromJson(json);

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;
}
