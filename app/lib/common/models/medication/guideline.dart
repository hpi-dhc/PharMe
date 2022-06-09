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
  String cpicGuidelineUrl;

  @HiveField(9)
  GenePhenotype genePhenotype;

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
        genePhenotype == other.genePhenotype;
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
      genePhenotype,
    );
  }
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

  @override
  bool operator ==(other) {
    return other is GenePhenotype &&
        phenotype.name == other.phenotype.name &&
        geneSymbol.name == other.geneSymbol.name;
  }

  @override
  int get hashCode => hashValues(phenotype.name, geneSymbol.name);
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
