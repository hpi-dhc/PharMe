import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';

import 'guideline.dart';

part 'medication.freezed.dart';
part 'medication.g.dart';

@freezed
class Medication with _$Medication {
  const factory Medication(
    int id,
    String name,
    String description,
    String? drugclass,
    String? indication,
  ) = _Medication;
  factory Medication.fromJson(dynamic json) => _$MedicationFromJson(json);
}

List<Medication> medicationsFromHTTPResponse(Response resp) {
  final json = jsonDecode(resp.body) as List<dynamic>;
  return json.map<Medication>(Medication.fromJson).toList();
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
