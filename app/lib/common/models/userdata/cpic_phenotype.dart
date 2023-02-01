import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'cpic_phenotype.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class CpicPhenotype {
  CpicPhenotype({
    required this.geneSymbol,
    required this.phenotype,
    required this.genotype,
    required this.lookupkey,
  });

  factory CpicPhenotype.fromJson(Map<String, dynamic> json) {
    // transform lookupkey map to string
    json['lookupkey'] = json['lookupkey'][json['genesymbol']];
    return _$CpicPhenotypeFromJson(json);
  }

  @HiveField(0)
  @JsonKey(name: 'genesymbol')
  String geneSymbol;

  @HiveField(1)
  @JsonKey(name: 'diplotype')
  String genotype;

  @HiveField(2)
  @JsonKey(name: 'generesult')
  String phenotype;

  @HiveField(3)
  @JsonKey(name: 'lookupkey')
  String lookupkey;
}
