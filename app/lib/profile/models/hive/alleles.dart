import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'diplotype.dart';

part 'alleles.g.dart';

@HiveType(typeId: 2)
@JsonSerializable(explicitToJson: true)
class Alleles {
  Alleles({
    required this.diplotypes,
  });

  factory Alleles.fromJson(Map<String, dynamic> json) =>
      _$AllelesFromJson(json);

  @HiveField(0)
  List<Diplotype> diplotypes;
}
