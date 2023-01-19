import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

import '../../module.dart';

part 'drug.g.dart';

@HiveType(typeId: 8)
@JsonSerializable()
class Drug {
  Drug({
    required this.id,
    required this.version,
    required this.name,
    required this.rxNorm,
    required this.annotations,
    required this.guidelines,
  });
  factory Drug.fromJson(dynamic json) => _$DrugFromJson(json);

  @HiveField(0)
  @JsonKey(name: '_id')
  String id;

  @HiveField(1)
  @JsonKey(name: '_v')
  int version;

  @HiveField(2)
  String name;

  @HiveField(3)
  String rxNorm;

  @HiveField(4)
  DrugAnnotations annotations;

  @HiveField(5)
  List<Guideline> guidelines;

  @override
  bool operator ==(other) => other is Drug && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 9)
@JsonSerializable()
class DrugAnnotations {
  DrugAnnotations({
    required this.drugclass,
    required this.indication,
    required this.brandNames,
  });
  factory DrugAnnotations.fromJson(dynamic json) =>
      _$DrugAnnotationsFromJson(json);

  @HiveField(0)
  String drugclass;

  @HiveField(1)
  String indication;

  @HiveField(2)
  List<String> brandNames;
}

List<Drug> drugsFromHTTPResponse(Response resp) {
  final json = jsonDecode(resp.body) as List<dynamic>;
  return json.map<Drug>(Drug.fromJson).toList();
}

List<Drug> drugsWithGuidelinesFromHTTPResponse(
  Response resp,
) {
  final json = jsonDecode(resp.body) as List<dynamic>;
  return json.map<Drug>(Drug.fromJson).toList();
}

Drug drugWithGuidelinesFromHTTPResponse(
  Response resp,
) {
  return Drug.fromJson(jsonDecode(resp.body));
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

extension DrugWithGuidelinesIsStarred on Drug {
  bool isStarred() {
    return UserData.instance.starredMediationIds?.contains(id) ?? false;
  }
}

extension DrugWithGuidelinesMatchesQuery on Drug {
  bool matches({required String query}) {
    return name.ilike(query) ||
        (description.isNotNullOrBlank && description!.ilike(query)) ||
        (drugclass.isNotNullOrBlank && drugclass!.ilike(query)) ||
        (synonyms != null && synonyms!.any((synonym) => synonym.ilike(query)));
  }
}

/// Removes the guidelines that are not relevant to the user
extension DrugWithUserGuidelines on Drug {
  Drug filterUserGuidelines() {
    final matchingGuidelines = guidelines.where((guideline) {
      final phenotype = guideline.phenotype;
      final foundEntry =
          UserData.instance.lookups![guideline.phenotype.geneSymbol.name];
      return foundEntry.isNotNullOrBlank &&
          foundEntry == phenotype.geneResult.name;
    });

    return Drug(
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
extension DrugsWithUserGuidelines on List<Drug> {
  List<Drug> filterUserGuidelines() {
    return map((drug) => drug.filterUserGuidelines()).toList();
  }
}

/// Filters for drugs with non-OK warning level
extension CriticalDrugs on List<Drug> {
  List<Drug> filterCritical() {
    return filter((drug) {
      final warningLevel = drug.highestWarningLevel();
      return warningLevel != null && warningLevel != WarningLevel.green;
    }).toList();
  }
}

/// Gets most severe warning level
extension DrugWarningLevel on Drug {
  WarningLevel? highestWarningLevel() {
    final filtered = filterUserGuidelines();
    return filtered.guidelines
        .map((guideline) => guideline.warningLevel)
        .filterNotNull()
        .maxBy((level) => level.severity);
  }
}
