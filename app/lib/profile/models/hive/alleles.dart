import 'package:hive/hive.dart';

import 'diplotype.dart';

part 'alleles.g.dart';

@HiveType(typeId: 2)
class Alleles {
  Alleles({
    required this.organizationId,
    required this.identifier,
    required this.knowledgeBase,
    required this.diplotypes,
  });

  factory Alleles.fromJson(Map<String, dynamic> json) => Alleles(
        organizationId: json['OrganizationId'] as int,
        identifier: json['Identifier'] as String,
        knowledgeBase: json['KnowledgeBase'] as String,
        diplotypes: (json['Diplotypes'] as List<dynamic>)
            .map((e) => Diplotype.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

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
