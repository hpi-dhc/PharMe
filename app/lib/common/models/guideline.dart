import 'package:freezed_annotation/freezed_annotation.dart';

part 'guideline.freezed.dart';
part 'guideline.g.dart';

@freezed
class Guideline with _$Guideline {
  const factory Guideline(
    int id,
    String? implication,
    String? recommendation,
    String? warningLevel,
    String? cpicRecommendation,
    String? cpicImplication,
    String? cpicClassification,
    String? cpicComment,
    GenePhenotype genePhenotype,
  ) = _Guideline;
  factory Guideline.fromJson(dynamic json) => _$GuidelineFromJson(json);
}

@freezed
class GenePhenotype with _$GenePhenotype {
  const factory GenePhenotype(
    int id,
    Phenotype phenotype,
    GeneSymbol geneSymbol,
  ) = _GenePhenotype;
  factory GenePhenotype.fromJson(dynamic json) => _$GenePhenotypeFromJson(json);
}

@freezed
class GeneSymbol with _$GeneSymbol {
  const factory GeneSymbol(int id, String name) = _GeneSymbol;
  factory GeneSymbol.fromJson(dynamic json) => _$GeneSymbolFromJson(json);
}

@freezed
class Phenotype with _$Phenotype {
  const factory Phenotype(int id, String name) = _Phenotype;
  factory Phenotype.fromJson(dynamic json) => _$PhenotypeFromJson(json);
}
