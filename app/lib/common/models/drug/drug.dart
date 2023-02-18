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

/// Gets the User's matching guideline
extension DrugWithUserGuideline on Drug {
  Guideline? userGuideline() => guidelines.firstOrNullWhere(
        (guideline) => guideline.lookupkey.all((geneSymbol, geneResults) =>
            geneResults.contains(UserData.lookupFor(geneSymbol))),
      );
}

/// Filters for drugs with non-OK warning level
extension CriticalDrugs on List<Drug> {
  List<Drug> filterCritical() {
    return filter((drug) {
      final warningLevel = drug.userGuideline()?.annotations.warningLevel;
      return warningLevel != null && warningLevel != WarningLevel.green;
    }).toList();
  }
}
