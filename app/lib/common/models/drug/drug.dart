import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

import '../../module.dart';

part 'drug.freezed.dart';
part 'drug.g.dart';

@freezed
class Drug with _$Drug {
  const factory Drug(
    int id,
    String name,
    String? description,
    String? drugclass,
    String? indication,
  ) = _Drug;
  factory Drug.fromJson(dynamic json) => _$DrugFromJson(json);
}

@HiveType(typeId: 8)
@JsonSerializable()
class DrugWithGuidelines {
  DrugWithGuidelines({
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
  factory DrugWithGuidelines.fromJson(dynamic json) =>
      _$DrugWithGuidelinesFromJson(json);

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
      other is DrugWithGuidelines &&
      name == other.name &&
      guidelines.contentEquals(other.guidelines);

  @override
  int get hashCode => Object.hash(name, guidelines);
}

List<Drug> drugsFromHTTPResponse(Response resp) {
  final json = jsonDecode(resp.body) as List<dynamic>;
  return json.map<Drug>(Drug.fromJson).toList();
}

List<DrugWithGuidelines> drugsWithGuidelinesFromHTTPResponse(
  Response resp,
) {
  final json = jsonDecode(resp.body) as List<dynamic>;
  return json.map<DrugWithGuidelines>(DrugWithGuidelines.fromJson).toList();
}

DrugWithGuidelines drugWithGuidelinesFromHTTPResponse(
  Response resp,
) {
  return DrugWithGuidelines.fromJson(jsonDecode(resp.body));
}

List<int> idsFromHTTPResponse(Response resp) {
  final idsList = jsonDecode(resp.body) as List<dynamic>;
  return idsList.map((e) => e['id'] as int).toList();
}

extension DrugIsStarred on Drug {
  bool isStarred() {
    return UserData.instance.starredMediationIds?.contains(id) ?? false;
  }
}

extension DrugWithGuidelinesIsStarred on DrugWithGuidelines {
  bool isStarred() {
    return UserData.instance.starredMediationIds?.contains(id) ?? false;
  }
}

extension DrugWithGuidelinesMatchesQuery on DrugWithGuidelines {
  bool matches({required String query}) {
    return name.ilike(query) ||
        (description.isNotNullOrBlank && description!.ilike(query)) ||
        (drugclass.isNotNullOrBlank && drugclass!.ilike(query)) ||
        (synonyms != null && synonyms!.any((synonym) => synonym.ilike(query)));
  }
}

/// Removes the guidelines that are not relevant to the user
extension DrugWithUserGuidelines on DrugWithGuidelines {
  DrugWithGuidelines filterUserGuidelines() {
    final matchingGuidelines = guidelines.where((guideline) {
      final phenotype = guideline.phenotype;
      final foundEntry =
          UserData.instance.lookups![guideline.phenotype.geneSymbol.name];
      return foundEntry.isNotNullOrBlank &&
          foundEntry == phenotype.geneResult.name;
    });

    return DrugWithGuidelines(
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
extension DrugsWithUserGuidelines on List<DrugWithGuidelines> {
  List<DrugWithGuidelines> filterUserGuidelines() {
    return map((drug) => drug.filterUserGuidelines()).toList();
  }
}

/// Filters for drugs with non-OK warning level
extension CriticalDrugs on List<DrugWithGuidelines> {
  List<DrugWithGuidelines> filterCritical() {
    return filter((drug) {
      final warningLevel = drug.highestWarningLevel();
      return warningLevel != null && warningLevel != WarningLevel.green;
    }).toList();
  }
}

/// Gets most severe warning level
extension DrugWarningLevel on DrugWithGuidelines {
  WarningLevel? highestWarningLevel() {
    final filtered = filterUserGuidelines();
    return filtered.guidelines
        .map((guideline) => guideline.warningLevel)
        .filterNotNull()
        .maxBy((level) => level.severity);
  }
}
