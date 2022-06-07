import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

import '../../module.dart';

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

@HiveType(typeId: 8)
@JsonSerializable()
class MedicationWithGuidelines {
  MedicationWithGuidelines({
    required this.id,
    required this.name,
    this.description,
    this.pharmgkbId,
    this.rxcui,
    this.synonyms,
    this.drugclass,
    this.indication,
    required this.guidelines,
  });
  factory MedicationWithGuidelines.fromJson(dynamic json) =>
      _$MedicationWithGuidelinesFromJson(json);

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? pharmgkbId;

  @HiveField(4)
  String? rxcui;

  @HiveField(5)
  List<String>? synonyms;

  @HiveField(6)
  String? drugclass;

  @HiveField(7)
  String? indication;

  @HiveField(8)
  List<Guideline> guidelines;

  @override
  bool operator ==(other) =>
      other is MedicationWithGuidelines &&
      name == other.name &&
      guidelines.contentEquals(other.guidelines);

  @override
  int get hashCode => hashValues(name, guidelines);
}

extension AddUniqueMedications on List<MedicationWithGuidelines>? {
  /// Returns a copy of the array by pushing only elements that are new to the array
  List<MedicationWithGuidelines> addUnique(
      List<MedicationWithGuidelines> newMedications) {
    if (this != null) {
      for (final element in newMedications) {
        if (!this!.contains(element)) {
          this!.add(element);
        }
      }
      return this!;
    } else {
      return newMedications;
    }
  }
}

List<Medication> medicationsFromHTTPResponse(Response resp) {
  final json = jsonDecode(resp.body) as List<dynamic>;
  return json.map<Medication>(Medication.fromJson).toList();
}

List<MedicationWithGuidelines> medicationsWithGuidelinesFromHTTPResponse(
  Response resp,
) {
  final json = jsonDecode(resp.body) as List<dynamic>;
  return json
      .map<MedicationWithGuidelines>(MedicationWithGuidelines.fromJson)
      .toList();
}

MedicationWithGuidelines medicationWithGuidelinesFromHTTPResponse(
  Response resp,
) {
  return MedicationWithGuidelines.fromJson(jsonDecode(resp.body));
}

List<int> idsFromHTTPResponse(Response resp) {
  final idsList = jsonDecode(resp.body) as List<dynamic>;
  return idsList.map((e) => e['id'] as int).toList();
}
