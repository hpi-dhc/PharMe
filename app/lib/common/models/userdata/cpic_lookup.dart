import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'genotype.dart';

part 'cpic_lookup.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class CpicLookup implements Genotype {
  CpicLookup({
    required this.gene,
    required this.phenotype,
    required this.variant,
    required this.lookupkey,
  });

  factory CpicLookup.fromJson(dynamic json) {
    return _$CpicLookupFromJson({
      ...json,
      // transform lookupkey map to string
      'lookupkey': json['lookupkey'][json['genesymbol']],
    });
  }

  @override
  @HiveField(0)
  @JsonKey(name: 'genesymbol')
  String gene;

  @override
  @HiveField(1)
  @JsonKey(name: 'diplotype')
  String variant;

  @HiveField(2)
  @JsonKey(name: 'generesult')
  String phenotype;

  @HiveField(3)
  @JsonKey(name: 'lookupkey')
  String lookupkey;
}
