import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../../module.dart';
part 'guideline.g.dart';

@HiveType(typeId: 8)
@JsonSerializable()
class Guideline {
  Guideline({
    required this.id,
    required this.version,
    required this.lookupkey,
    required this.cpicData,
    required this.annotations,
  });
  factory Guideline.fromJson(dynamic json) => _$GuidelineFromJson(json);

  @HiveField(0)
  @JsonKey(name: '_id')
  String id;

  @HiveField(1)
  @JsonKey(name: '_v')
  int version;

  @HiveField(2)
  // gene-symbol: gene-results
  Map<String, List<String>> lookupkey;

  @HiveField(3)
  GuidelineCpicData cpicData;

  @HiveField(4)
  GuidelineAnnotations annotations;

  @override
  bool operator ==(other) {
    return other is Guideline && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

@HiveType(typeId: 9)
@JsonSerializable()
class GuidelineAnnotations {
  GuidelineAnnotations({
    required this.recommendation,
    required this.implication,
    required this.warningLevel,
  });
  factory GuidelineAnnotations.fromJson(dynamic json) =>
      _$GuidelineAnnotationsFromJson(json);

  @HiveField(0)
  String recommendation;

  @HiveField(1)
  String implication;

  @HiveField(2)
  WarningLevel warningLevel;
}

@HiveType(typeId: 10)
@JsonSerializable()
class GuidelineCpicData {
  GuidelineCpicData({
    required this.guidelineName,
    required this.guidelineUrl,
    required this.implications,
    required this.recommendation,
    required this.comments,
  });
  factory GuidelineCpicData.fromJson(dynamic json) =>
      _$GuidelineCpicDataFromJson(json);

  @HiveField(0)
  String guidelineName;

  @HiveField(1)
  String guidelineUrl;

  @HiveField(2)
  Map<String, String> implications;

  @HiveField(3)
  String recommendation;

  @HiveField(4)
  String comments;
}
