import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../../module.dart';

part 'drug.g.dart';

@HiveType(typeId: 6)
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

@HiveType(typeId: 7)
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

extension DrugIsStarred on Drug {
  bool isStarred() {
    return UserData.instance.starredDrugIds?.contains(id) ?? false;
  }
}

extension DrugMatchesQuery on Drug {
  bool matches({required String query}) {
    return name.ilike(query) ||
        (annotations.drugclass.ilike(query)) ||
        (annotations.brandNames.any((brand) => brand.ilike(query)));
  }
}

/// Removes the guidelines that are not relevant to the user
extension DrugWithUserGuidelines on Drug {
  Drug filterUserGuidelines() {
    final matchingGuidelines = guidelines.where((guideline) {
      // Guideline matches if all user has any of the gene results for all gene
      // symbols
      return guideline.lookupkey.all((geneSymbol, geneResults) =>
          (UserData.instance.lookups?.containsKey(geneSymbol) ?? false) &&
          geneResults.contains(UserData.instance.lookups?[geneSymbol]));
    });

    return Drug(
      id: id,
      version: version,
      name: name,
      rxNorm: rxNorm,
      annotations: annotations,
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
        .map((guideline) => guideline.annotations.warningLevel)
        .maxBy((level) => level.severity);
  }
}
