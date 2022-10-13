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
    String? description,
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
    this.isCritical = false,
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

  // Indicates whether this medication is used in the reports
  @HiveField(9)
  bool isCritical;

  @override
  bool operator ==(other) =>
      other is MedicationWithGuidelines &&
      name == other.name &&
      guidelines.contentEquals(other.guidelines);

  @override
  int get hashCode => Object.hash(name, guidelines);
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

extension MedicationIsStarred on Medication {
  bool isStarred() {
    return UserData.instance.starredMediationIds?.contains(id) ?? false;
  }
}

extension MedicationWithGuidelinesIsStarred on MedicationWithGuidelines {
  bool isStarred() {
    return UserData.instance.starredMediationIds?.contains(id) ?? false;
  }
}

/// Removes the guidelines that are not relevant to the user
extension MedicationWithUserGuidelines on MedicationWithGuidelines {
  MedicationWithGuidelines filterUserGuidelines() {
    final matchingGuidelines = guidelines.where((guideline) {
      final phenotype = guideline.phenotype;
      final foundEntry =
          UserData.instance.lookups![guideline.phenotype.geneSymbol.name];
      return foundEntry.isNotNullOrBlank &&
          foundEntry == phenotype.geneResult.name;
    });

    return MedicationWithGuidelines(
      id: id,
      name: name,
      description: description,
      pharmgkbId: pharmgkbId,
      rxcui: rxcui,
      synonyms: synonyms,
      drugclass: drugclass,
      indication: indication,
      guidelines: matchingGuidelines.toList(),
    );
  }
}

/// Removes the guidelines that are not relevant to the user
extension MedicationsWithUserGuidelines on List<MedicationWithGuidelines> {
  List<MedicationWithGuidelines> filterUserGuidelines() {
    return map((medication) => medication.filterUserGuidelines()).toList();
  }
}

/// Filters for medications with non-OK warning level
extension CriticalMedications on List<MedicationWithGuidelines> {
  List<MedicationWithGuidelines> filterCritical() {
    final withRelevantGuidelines =
        map((medication) => medication.filterUserGuidelines());

    final withCriticalGuidelines = withRelevantGuidelines.where((element) {
      if (element.guidelines.isEmpty) return false;
      final warningLevels = element.guidelines.map((e) => e.warningLevel);
      return !warningLevels
          .every((warningLevel) => warningLevel == WarningLevel.ok.name);
    }).map((medication) {
      medication.isCritical = true;
      return medication;
    });

    return withCriticalGuidelines.toList();
  }
}
