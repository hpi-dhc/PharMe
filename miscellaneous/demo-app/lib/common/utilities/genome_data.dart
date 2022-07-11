import 'dart:collection';
import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../models/module.dart';

Future<void> fetchAndSaveDiplotypes() async {
  if (!shouldFetchDiplotypes()) return;
  final jsonFile = await rootBundle.loadString('assets/data/diplotypes.json');
  final json = jsonDecode(jsonFile)['diplotypes'] as List<dynamic>;
  final diplotypes =
      json.map<Diplotype>(Diplotype.fromJson).toList().filterValidDiplotypes();
  UserData.instance.diplotypes = diplotypes;
  await UserData.save();
}

Future<void> fetchAndSaveLookups() async {
  if (!shouldFetchLookups()) return;

  // the returned json is a list of lookups which we wish to individually map
  // to a concrete CpicLookup instance, hence the cast to a List
  final jsonFile = await rootBundle.loadString('assets/data/lookups.json');
  final json = jsonDecode(jsonFile) as List<dynamic>;
  final lookups = json.map<CpicLookup>(CpicLookup.fromJson);
  final usersDiplotypes = UserData.instance.diplotypes;
  if (usersDiplotypes == null) throw Exception();

  // use a HashMap for better time complexity
  final lookupsHashMap = HashMap<String, String>.fromIterable(
    lookups,
    key: (el) => '${el.genesymbol}__${el.diplotype}',
    value: (el) => el.generesult,
  );
  // ignore: omit_local_variable_types
  final Map<String, String> matchingLookups = {};
  // extract the matching lookups
  for (final diplotype in usersDiplotypes) {
    if (diplotype.genotype.contains('-')) {
      // TODO(kolioOtSofia): what to do with genotypes that contain -
    }
    // the gene and the genotype build the key for the hashmap
    final key = '${diplotype.gene}__${diplotype.genotype}';
    final temp = lookupsHashMap[key];
    if (temp.isNotNullOrBlank) matchingLookups[diplotype.gene] = temp!;
  }

  UserData.instance.lookups = matchingLookups;
  await UserData.save();

  // Save datetime at which lookups were fetched
  MetaData.instance.lookupsLastFetchDate = DateTime.now();
  await MetaData.save();
}

bool shouldFetchLookups() {
  final lookupsPresent = UserData.instance.lookups?.isNotEmpty ?? false;
  final diplotypesPresent = UserData.instance.diplotypes?.isNotEmpty ?? false;
  final result = (_isOutDated() || !lookupsPresent) && diplotypesPresent;
  return result;
}

bool shouldFetchDiplotypes() {
  return UserData.instance.diplotypes == null;
}

bool _isOutDated() {
  final lastFetchDate = MetaData.instance.lookupsLastFetchDate;
  if (lastFetchDate == null) return true;
  return DateTime.now().difference(lastFetchDate) > cpicMaxCacheTime;
}
