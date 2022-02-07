// ignore_for_file: non_constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

part 'diplotype.freezed.dart';
part 'diplotype.g.dart';

@freezed
class Diplotype with _$Diplotype {
  const factory Diplotype(String Gene, String ResultType, String Genotype, String Phenotype, String AllelesTested) = _Diplotype;
  factory Diplotype.fromJson(Map<String, dynamic> json) => _$DiplotypeFromJson(json);
}
