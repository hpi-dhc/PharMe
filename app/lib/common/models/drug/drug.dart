import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:trotter/trotter.dart';

import '../../../app.dart';
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

  bool _lookupsMatchUserData(String gene, List<String> variants) =>
    variants.any((variant) => variants.contains(
      UserData.lookupFor(
        GenotypeKey(gene, variant).value,
        drug: name,
      ),
    ));

  Guideline? _getExactGuideline() {
    final exactGuidelines = guidelines.filter(
      (guideline) => guideline.lookupkey.none(
        (gene, variants) => variants.contains(SpecialLookup.anyNotHandled.value)
      )
    );
    return exactGuidelines.firstOrNullWhere(
      (guideline) => guideline.lookupkey.all(_lookupsMatchUserData)
    );
  }

  Guideline? _getPartiallyHandledGuideline() {
    if (guidelines.isEmpty) return null;
    final partialGuidelines = guidelines.filter(
      (guideline) => guideline.lookupkey.values.any(
        (values) => values.contains(SpecialLookup.anyNotHandled.value),
      ),
    );
    if (partialGuidelines.isEmpty) return null;
    final guidelineGenes = guidelines.first.genes;
    Guideline? partiallyHandledGuideline;
    var currentMatchingNumber = guidelineGenes.length - 1;
    while (currentMatchingNumber > 0 && partiallyHandledGuideline == null) {
      final currentGeneCombinations =
        Combinations(currentMatchingNumber, guidelineGenes)().toList();
      for (final geneCombination in currentGeneCombinations) {
        if (partiallyHandledGuideline != null) break;
        partiallyHandledGuideline = partialGuidelines.firstOrNullWhere(
          (guideline) => guideline.lookupkey.all(
            (gene, variants) => geneCombination.contains(gene)
              ? _lookupsMatchUserData(gene, variants)
              : variants.any(
                (variant) => variant == SpecialLookup.anyNotHandled.value
              ),
          ),
        );
      }
      currentMatchingNumber--;
    }
    return partiallyHandledGuideline;
  }

  Guideline? get userGuideline {
    final anyFallbackGuideline = guidelines.firstOrNullWhere(
      (guideline) => guideline.lookupkey.all(
        (gene, variants) => variants.any(
          (variant) => variant == SpecialLookup.any.value
        )
      ),
    );
    if (anyFallbackGuideline != null) return anyFallbackGuideline;
    final exactGuideline = _getExactGuideline();
    if (exactGuideline != null) return exactGuideline;
    final partiallyHandledGuideline = _getPartiallyHandledGuideline();
    if (partiallyHandledGuideline != null) return partiallyHandledGuideline;
    final completelyUnhandledGuideline = guidelines.firstOrNullWhere(
      (guideline) => guideline.lookupkey.all(
        (gene, variants) => variants.any(
          (variant) => variant == SpecialLookup.anyNotHandled.value
        )
      )
    );
    final context = PharMeApp.navigatorKey.currentContext;
    if (
      completelyUnhandledGuideline != null &&
      completelyUnhandledGuideline.isFdaGuideline &&
      context != null
    ) {      
      final isCompletelyIndeterminateResult = guidelineGenotypes.map(
        (genotypeKey) => UserData.instance.genotypeResults?[genotypeKey]
      ).all(
        (genotypeResult) =>
          genotypeResult != null &&
          genotypeResult.phenotypeDisplayString(context) == indeterminateResult
      );
      if (isCompletelyIndeterminateResult) {
        final indeterminateFdaFallbackGuideline = Guideline.fromJson(
          completelyUnhandledGuideline.toJson(),
        );
        indeterminateFdaFallbackGuideline.annotations.implication =
          context.l10n.drugs_page_fda_indeterminate_implication_text(name);
        indeterminateFdaFallbackGuideline.annotations.recommendation = 
          context.l10n.drugs_page_no_guidelines_recommendation_text;
        indeterminateFdaFallbackGuideline.annotations.warningLevel =
          WarningLevel.none;
        return indeterminateFdaFallbackGuideline;
      }
    }
    return completelyUnhandledGuideline;
  }

  Guideline? get userOrFirstGuideline => userGuideline ??
    (guidelines.isNotEmpty ? guidelines.first : null);

  List<String> get guidelineGenotypes {
    if (guidelines.isEmpty) return [];
    final genotypeKeys = <String, GenotypeKey>{};
    final lookupGeneCount = guidelines.first.lookupkey.keys.length;
    for (final guideline in guidelines) {
      if (genotypeKeys.length == lookupGeneCount) break;
      for (final lookupEntry in guideline.lookupkey.entries) {
        final gene = lookupEntry.key;
        GenotypeKey? genotypeKey;
        if (isGeneUnique(gene)) {
          genotypeKey = GenotypeKey(gene, null);
        } else {
          for (final variant in lookupEntry.value) {
            if (variant == SpecialLookup.noResult.value) continue;
            genotypeKey = GenotypeKey(gene, variant);
          }
        }
        if (genotypeKey != null) {
          genotypeKeys[genotypeKey.value] = genotypeKey;
        }
      }
    }
    return genotypeKeys.values.map((genotypeKey) => genotypeKey.value).toList();
  }

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
  {
    bool capitalize = false,
    String? brandNamesPrefix,
  }
) {
  return drugNames?.map(
    (drugName) => _getDrugWithBrandNames(
      drugName,
      capitalize: capitalize,
      brandNamesPrefix: brandNamesPrefix,
    )
  ).toList() ?? [];
}

String _getDrugWithBrandNames(
  String drugName,
  {
    bool capitalize = false,
    String? brandNamesPrefix,
  }
) {
  final drug = DrugsWithGuidelines.instance.drugs?.firstOrNullWhere(
    (drug) => drug.name == drugName
  );
  final displayedDrugName = capitalize ? drugName.capitalize() : drugName;
  if (drug == null || drug.annotations.brandNames.isEmpty) {
    return displayedDrugName;
  }
  final branNamesString = drug.annotations.brandNames.join(', ');
  return brandNamesPrefix != null
    ? '$displayedDrugName ($brandNamesPrefix: $branNamesString)'
    : '$displayedDrugName ($branNamesString)';
}
