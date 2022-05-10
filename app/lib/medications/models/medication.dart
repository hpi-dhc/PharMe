import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';

part 'medication.freezed.dart';
part 'medication.g.dart';

@freezed
class Medication with _$Medication {
  const factory Medication(int id, String name, String description,
      String? drugclass, String? indication) = _Medication;
  factory Medication.fromJson(dynamic json) => _$MedicationFromJson(json);
}

List<Medication> medicationsFromHTTPResponse(Response resp) {
  final json = jsonDecode(resp.body) as List<dynamic>;
  return json.map<Medication>(Medication.fromJson).toList();
}

@freezed
class GeneSymbol with _$GeneSymbol {
  const factory GeneSymbol(int id, String name) = _GeneSymbol;
  factory GeneSymbol.fromJson(dynamic json) => _$GeneSymbolFromJson(json);
}

@freezed
class Phenotype with _$Phenotype {
  const factory Phenotype(int id, String lookupkey, String name) = _Phenotype;
  factory Phenotype.fromJson(dynamic json) => _$PhenotypeFromJson(json);
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
class MedicationWithGuidelines with _$MedicationWithGuidelines {
  const factory MedicationWithGuidelines(
    int id,
    String name,
    String? description,
    String? pharmgkbId,
    String? rxcui,
    List<String> synonyms,
    String? drugclass,
    String? indication,
    List<Guideline> guidelines,
  ) = _MedicationWithGuidelines;
  factory MedicationWithGuidelines.fromJson(dynamic json) =>
      _$MedicationWithGuidelinesFromJson(json);
}

List<MedicationWithGuidelines> medicationsWithGuidelinesFromHTTPResponse(
    Response resp) {
  final json = jsonDecode(resp.body) as List<dynamic>;
  return json
      .map<MedicationWithGuidelines>(MedicationWithGuidelines.fromJson)
      .toList();
}
