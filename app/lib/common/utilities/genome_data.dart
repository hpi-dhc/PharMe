import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart';

import '../constants.dart';
import '../models/module.dart';

Future<void> fetchAndSaveDiplotypesAndActiveDrugs(
  String token, String url, ActiveDrugs activeDrugs) async {
  if (!shouldFetchDiplotypes()) return;
  final response = await getDiplotypes(token, url);
  if (response.statusCode == 200) {
    await _saveDiplotypeAndActiveDrugsResponse(response, activeDrugs);
  } else {
    throw Exception();
  }
}

Future<Response> getDiplotypes(String? token, String url) async {
  return get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
}

String getGenotypeKey(Genotype genotype) {
  // If gene is unique return gene; else return gene plus first part of variant
  // (before space)
  return genotype.gene;
}

Future<void> _saveDiplotypeAndActiveDrugsResponse(
  Response response,
  ActiveDrugs activeDrugs,
) async {
  // parse response to list of user's diplotypes
  final diplotypes =
      geneResultsFromHTTPResponse(response);
  final activeDrugList = activeDrugsFromHTTPResponse(response);

  UserData.instance.geneResults = {
    for (final diplotype in diplotypes) diplotype.gene: diplotype
  };
  await UserData.save();
  await activeDrugs.setList(activeDrugList);
  // invalidate cached drugs because lookups may have changed and we need to
  // refilter the matching guidelines
  await CachedDrugs.erase();
}

Future<void> fetchAndSaveLookups() async {
  if (!shouldFetchLookups()) return;
  final response = await get(Uri.parse(cpicLookupUrl));
  if (response.statusCode != 200) throw Exception();

  // the returned json is a list of lookups which we wish to individually map
  // to a concrete LookupInformation instance, hence the cast to a List
  final json = jsonDecode(response.body) as List<dynamic>;
  final lookups = json.map(LookupInformation.fromJson);
  final geneResults = UserData.instance.geneResults;
  if (geneResults == null) throw Exception();

  // use a HashMap for better time complexity
  final lookupsHashMap = HashMap<String, LookupInformation>.fromIterable(
    lookups,
    key: (lookup) => '${lookup.gene}__${lookup.variant}',
    value: (lookup) => lookup,
  );
  // ignore: omit_local_variable_types
  final Map<String, LookupInformation> matchingLookups = {};
  // extract the matching lookups
  for (final geneResult in geneResults.values) {
    // the gene and the genotype build the key for the hashmap
    final key = '${geneResult.gene}__${geneResult.variant}';
    final lookup = lookupsHashMap[key];
    if (lookup == null) continue;
    // uncomment to print literal mismatches between lab/CPIC phenotypes
    // if (geneResult.phenotype != lookup.phenotype) {
    //   print(
    //       'Lab phenotype ${geneResult.phenotype} for ${geneResult.gene} (${geneResult.genotype}) is "${lookup.phenotype}" for CPIC');
    // }
    matchingLookups[geneResult.gene] = lookup;
  }

  // uncomment to make user have CYP2D6 lookupkey 0.0
  // matchingLookups['CYP2D6'] = lookupsHashMap['CYP2D6__*100/*100']!;

  UserData.instance.lookups = matchingLookups;
  await UserData.save();

  // Save datetime at which lookups were fetched
  MetaData.instance.lookupsLastFetchDate = DateTime.now();
  await MetaData.save();
}

bool shouldFetchLookups() {
  final lookupsPresent = UserData.instance.lookups?.isNotEmpty ?? false;
  final diplotypesPresent = UserData.instance.geneResults?.isNotEmpty ?? false;
  return (_isOutDated() || !lookupsPresent) && diplotypesPresent;
}

bool shouldFetchDiplotypes() {
  return UserData.instance.geneResults == null;
}

bool _isOutDated() {
  final lastFetchDate = MetaData.instance.lookupsLastFetchDate;
  if (lastFetchDate == null) return true;
  return DateTime.now().difference(lastFetchDate) > cpicMaxCacheTime;
}
