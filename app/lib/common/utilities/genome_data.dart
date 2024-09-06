import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart';

import '../module.dart';

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

Future<void> _saveDiplotypeAndActiveDrugsResponse(
  Response response,
  ActiveDrugs activeDrugs,
) async {
  // parse response to list of user's labData
  final labData =
      labDataFromHTTPResponse(response);
  final activeDrugList = activeDrugsFromHTTPResponse(response);

  UserData.instance.labData = labData;
  await UserData.save();
  await activeDrugs.setList(activeDrugList);
  // invalidate cached drugs because lookups may have changed and we need to
  // refilter the matching guidelines
  await CachedDrugs.erase();
}

String formatLookupMapKey(String gene, String variant) {
  return '${gene}__$variant';
}

Future<void> updateGenotypeResults() async {
  final skipUpdate = !shouldUpdateGenotypeResults();
  if (skipUpdate) return;
  // fetch lookups
  final response = await get(Uri.parse(cpicLookupUrl));
  if (response.statusCode != 200) throw Exception();
  final json = jsonDecode(response.body) as List<dynamic>;
  final lookups = json.map(LookupInformation.fromJson);

  // use a HashMap for better time complexity
  // also add lookupkey for genes where, e.g., activity scores are reported as
  // genotype, such as DPYD or "Indeterminate"
  final Map<String, LookupInformation> lookupsHashMap = HashMap();
  for (final lookup in lookups) {
    final variantKey = formatLookupMapKey(lookup.gene, lookup.variant);
    final lookupKey = formatLookupMapKey(lookup.gene, lookup.lookupkey);
    lookupsHashMap[variantKey] = lookup;
    if (variantKey != lookupKey) lookupsHashMap[lookupKey] = lookup;
  }
  final genotypeResults = <String, GenotypeResult>{};
  // we know that labData is present because we check this in
  // shouldUpdateGenotypeResults
  for (final labResult in UserData.instance.labData!) {
    final lookupMapKey = formatLookupMapKey(labResult.gene, labResult.variant);
    final lookup = lookupsHashMap[lookupMapKey];
    if (lookup == null) continue;
    final genotypeResult = GenotypeResult.fromGenotypeData(labResult, lookup);
    genotypeResults[genotypeResult.key.value] = genotypeResult;
  }

  UserData.instance.genotypeResults = genotypeResults;
  await UserData.save();

  // Save datetime at which lookups were fetched
  MetaData.instance.lookupsLastFetchDate = DateTime.now();
  await MetaData.save();
}

bool shouldUpdateGenotypeResults() {
  final genotypeResultsPresent =
    UserData.instance.labData?.isNotEmpty ?? false;
  final lookupsAreOutdated = MetaData.instance.lookupsLastFetchDate == null ||
    DateTime.now().difference(MetaData.instance.lookupsLastFetchDate!) >
      cpicMaxCacheTime;
  final labDataPresent = UserData.instance.labData?.isNotEmpty ?? false;
  return labDataPresent && (!genotypeResultsPresent || lookupsAreOutdated);
}

bool shouldFetchDiplotypes() {
  return UserData.instance.labData == null;
}
