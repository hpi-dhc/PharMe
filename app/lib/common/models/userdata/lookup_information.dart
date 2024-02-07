import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'genotype.dart';

part 'lookup_information.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class LookupInformation implements Genotype {
  LookupInformation({
    required this.gene,
    required this.phenotype,
    required this.variant,
    required this.lookupkey,
  });

  factory LookupInformation.fromJson(dynamic json) {
    return _$LookupInformationFromJson({
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
