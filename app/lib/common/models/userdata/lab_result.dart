import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'genotype.dart';

part 'lab_result.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class LabResult implements Genotype {
  LabResult({
    required this.gene,
    required this.variant,
    required this.phenotype,
    required this.allelesTested,
  });

  factory LabResult.fromJson(dynamic json) => _$LabResultFromJson(json);
  Map<String, dynamic> toJson() => _$LabResultToJson(this);

  @override
  @HiveField(0)
  String gene;

  @override
  @HiveField(1)
  @JsonKey(name: 'genotype')
  String variant;

  @HiveField(2)
  String phenotype;

  @HiveField(3)
  String allelesTested;
}
