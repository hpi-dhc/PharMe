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

Future<void> updateGenotypeResults() async {
  if (!shouldUpdateGenotypeResults()) return;
  // fetch lookups
  final response = await get(Uri.parse(cpicLookupUrl));
  if (response.statusCode != 200) throw Exception();
  final json = jsonDecode(response.body) as List<dynamic>;
  final lookups = json.map(LookupInformation.fromJson);

  // use a HashMap for better time complexity
  final lookupsHashMap = HashMap<String, LookupInformation>.fromIterable(
    lookups,
    key: (lookup) => '${lookup.gene}__${lookup.variant}',
    value: (lookup) => lookup,
  );
  final genotypeResults = <String, GenotypeResult>{};
  // we know that labData is present because we check this in
  // shouldUpdateGenotypeResults
  for (final labResult in UserData.instance.labData!) {
    final key = '${labResult.gene}__${labResult.variant}';
    final lookup = lookupsHashMap[key];
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
  final labDataPresent = UserData.instance.labData?.isNotEmpty ?? false;
  return (!genotypeResultsPresent || _isOutDated()) && labDataPresent;
}

bool shouldFetchDiplotypes() {
  return UserData.instance.labData == null;
}

bool _isOutDated() {
  final lastFetchDate = MetaData.instance.lookupsLastFetchDate;
  if (lastFetchDate == null) return true;
  return DateTime.now().difference(lastFetchDate) > cpicMaxCacheTime;
}
