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
    // TODO(kolioOtSofia): extract those entries from the annotation server
    final acceptedLookupKeys = [
      //
      'carrier', 'decreased function', 'expressor for cyp3a5',
      'extensive metabolizer', 'increased function', 'indeterminate',
      'intermediate metabolizer',
      'intermediate metabolizer (controversy remains)',
      'intermediate metabolizer as of 1 (cyp2c9)',
      'intermediate metabolizer as of 1.5 (cyp2c9)',
      'intermediate metabolizer with activity score of 1',
      'intermediate metabolizer with activity score of 1.5',
      'intermediate warfarin dose requirement (vk c1 ag /ga)',
      'intermediate warfarin dose requirement (vk c1 ag /ga) poor metabolizer',
      'likely intermediate metabolizer',
      'likely poor metabolizer', 'low wafarin dose requirement (vk c1 aa)',
      'non-carrier', 'normal function', 'normal metabolizer',
      'normal warfarin dose requirement (vk c1 gg)', 'poor function',
      'poor metabolizer', 'possible decreased function', 'rapid metabolizer',
      'rapid metabolizer (cyp2c19)', 'ultrarapid metabolizer', 'variant',
    ];
    return where((element) => acceptedLookupKeys
        .contains(element.lookupkey.values.first.toLowerCase())).toList();
  }
}
