// ignore_for_file: non_constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

import 'diplotype.dart';

part 'alleles.freezed.dart';
part 'alleles.g.dart';

@freezed
class Alleles with _$Alleles {
  const factory Alleles(int OrganizationId, String Identifier, String KnowledgeBase, List<Diplotype> Diplotypes) = _Alleles;
  factory Alleles.fromJson(Map<String, dynamic> json) => _$AllelesFromJson(json);
}
