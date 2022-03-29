import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'diplotype.dart';

part 'alleles.g.dart';

@HiveType(typeId: 2)
@JsonSerializable(explicitToJson: true)
class Alleles {
  Alleles({
    required this.organizationId,
    required this.identifier,
    required this.knowledgeBase,
    required this.diplotypes,
  });

  factory Alleles.fromJson(Map<String, dynamic> json) =>
      _$AllelesFromJson(json);

  @HiveField(0)
  int organizationId;

  @HiveField(1)
  String identifier;

  @HiveField(2)
  String knowledgeBase;

  @HiveField(3)
  List<Diplotype> diplotypes;

  @override
  String toString() {
    return identifier;
  }
}
