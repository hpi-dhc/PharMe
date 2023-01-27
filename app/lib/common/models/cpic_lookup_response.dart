import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'cpic_lookup_response.g.dart';

typedef Lookup = Map<String, String>;

@HiveType(typeId: 2)
@JsonSerializable()
class CpicLookup {
  CpicLookup({
    required this.genesymbol,
    required this.diplotype,
    required this.generesult,
  });

  factory CpicLookup.fromJson(dynamic json) => _$CpicLookupFromJson(json);

  @HiveField(0)
  String genesymbol;

  @HiveField(1)
  String diplotype;

  @HiveField(2)
  String generesult;
}
