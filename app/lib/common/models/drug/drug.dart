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
  bool operator == (other) => other is Drug && id == other.id;

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

extension DrugExtension on Drug {
  bool get isActive =>
    UserData.instance.activeDrugNames?.contains(name) ?? false;

  bool matches({required String query, required bool useClass}) {
    final namesMatch = name.ilike(query) ||
      (annotations.brandNames.any((brand) => brand.ilike(query)));
    return useClass
      ? namesMatch || (annotations.drugclass.ilike(query))
      : namesMatch;
  }

  Guideline? get userGuideline {
    final anyFallbackGuideline = guidelines.firstOrNullWhere(
      (guideline) => guideline.lookupkey.all(
        (gene, variants) => variants.any((variant) => variant == '*')
      ),
    );
    if (anyFallbackGuideline != null) return anyFallbackGuideline;
    return guidelines.firstOrNullWhere(
      (guideline) => guideline.lookupkey.all(
        (gene, variants) => variants.any((variant) =>
          variants.contains(UserData.lookupFor(
            GenotypeKey(gene, variant).value,
            drug: name,
          )
        )),
      ),
    );
  }

  Guideline? get userOrFirstGuideline => userGuideline ??
    (guidelines.isNotEmpty ? guidelines.first : null);

  List<String> get guidelineGenotypes => guidelines.isNotEmpty
    ? guidelines.first.lookupkey.keys.flatMap(
      (gene) => guidelines.first.lookupkey[gene]!.map((variant) =>
        GenotypeKey(gene, variant).value
      ).toList().toSet()
    ).toList()
    : [];

  WarningLevel get warningLevel =>
    userGuideline?.annotations.warningLevel ?? WarningLevel.none;
}

/// Filters for drugs with non-OK warning level
extension CriticalDrugs on List<Drug> {
  List<Drug> filterCritical() {
    return filter((drug) {
      return drug.warningLevel != WarningLevel.none &&
        drug.warningLevel != WarningLevel.green;
    }).toList();
  }
}

List<String> getDrugsWithBrandNames(
  List<String>? drugNames,
  { bool capitalize = false }
) {
  return drugNames?.map(
    (drugName) => _getDrugWithBrandNames(drugName, capitalize: capitalize)
  ).toList() ?? [];
}

String _getDrugWithBrandNames(
  String drugName,
  { required bool capitalize }
) {
  final drug = CachedDrugs.instance.drugs?.firstOrNullWhere(
    (drug) => drug.name == drugName
  );
  final displayedDrugName = capitalize ? drugName.capitalize() : drugName;
  if (drug == null || drug.annotations.brandNames.isEmpty) {
    return displayedDrugName;
  }
  return '$displayedDrugName (${drug.annotations.brandNames.join(', ')})';
}
