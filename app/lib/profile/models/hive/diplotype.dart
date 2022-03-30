import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'diplotype.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Diplotype {
  Diplotype({
    required this.gene,
    required this.resultType,
    required this.genotype,
    required this.phenotype,
    required this.allelesTested,
  });

  factory Diplotype.fromJson(Map<String, dynamic> json) =>
      _$DiplotypeFromJson(json);
  Map<String, dynamic> toJson() => _$DiplotypeToJson(this);

  @HiveField(0)
  String gene;

  @HiveField(1)
  String resultType;

  @HiveField(2)
  String genotype;

  @HiveField(3)
  String phenotype;

  @HiveField(4)
  String allelesTested;

  @override
  String toString() {
    return gene;
  }
}
