import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'cpic_lookup_response.g.dart';

typedef Lookup = Map<String, String>;

@HiveType(typeId: 3)
@JsonSerializable()
class CpicLookup {
  CpicLookup({
    required this.genesymbol,
    required this.diplotype,
    required this.lookupkey,
  });

  factory CpicLookup.fromJson(Map<String, dynamic> json) =>
      _$CpicLookupFromJson(json);

  @HiveField(0)
  String genesymbol;

  @HiveField(1)
  String diplotype;

  @HiveField(2)
  Lookup lookupkey;
}

extension FilteredList on Iterable<CpicLookup> {
  List<CpicLookup> filterValidLookups() {
    final acceptedLookupKeys = [
      'Rapid Metabolizer',
      'Intermediate Metabolizer',
      'Normal Metabolizer',
      'Poor Metabolizer'
    ];
    return where((element) =>
        acceptedLookupKeys.contains(element.lookupkey.values.first)).toList();
  }
}
