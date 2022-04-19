import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart';

import '../../profile/models/hive/alleles.dart';
import '../../profile/models/hive/cpic_lookup_response.dart';
import '../../profile/models/hive/diplotype.dart';
import '../constants.dart';
import '../services.dart';

Future<void> fetchAndSaveAllesData(String token, String url) async {
  final userAlleleData = getBox<Alleles>(Boxes.alleles);
  if (userAlleleData.get('alleles') == null) {
    final response = await getStarAlleles(token, url);
    if (response.statusCode == 200) {
      await _saveAlleleData(response);
    } else {
      throw Exception('Error occurred during loading of allele data');
    }
  }
}

Future<Response> getStarAlleles(String? token, String url) async =>
    get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});

Future<void> _saveAlleleData(Response response) async {
  final json = jsonDecode(response.body);
  final alleles = Alleles.fromJson(json);
  alleles.diplotypes = alleles.diplotypes.filterValidDiplotypes();
  return getBox<Alleles>(Boxes.alleles).put('alleles', alleles);
}

Future<void> fetchAndSaveLookups() async {
  if (!shouldFetchLookups()) return;
  final response = await get(Uri.parse(cpicLookupUrl));
  if (response.statusCode != 200)
    // ignore: curly_braces_in_flow_control_structures
    throw Exception('Error while loading lookups');

  final json = jsonDecode(response.body) as List<dynamic>;
  final lookups =
      // ignore: unnecessary_lambdas
      json.map((el) => CpicLookup.fromJson(el)).filterValidLookups();
  final usersAlleles = getBox<Alleles>(Boxes.alleles).get('alleles');

  // use a HashMap for better time complexity
  final lookupsHashMap = HashMap<String, Lookup>.fromIterable(
    lookups,
    key: (el) => '${el.genesymbol}${el.diplotype}',
    value: (el) => el.lookupkey,
  );
  // ignore: omit_local_variable_types
  final List<Lookup> matchingLookups = [];
  // extract the matching lookups
  for (final diplotype in usersAlleles!.diplotypes) {
    // the gene and the genotype build the key for the hashmap
    final temp = lookupsHashMap['${diplotype.gene}${diplotype.genotype}'];
    if (temp != null) matchingLookups.add(temp);
  }

  await getBox<List<Lookup>>(Boxes.lookups).put('lookups', matchingLookups);

  // Save datetime at which lookups were fetched
  await getBox<DateTime>(Boxes.lookupsLastFetch)
      .put('lookupsLastFetch', DateTime.now());
}

bool shouldFetchLookups() {
  return _isOutDated() || getBox<List<Lookup>>(Boxes.lookups).isEmpty;
}

bool _isOutDated() {
  final lastFetchDate =
      getBox<DateTime>(Boxes.lookupsLastFetch).get('lookupsLastFetch');
  if (lastFetchDate == null) {
    return true;
  }
  return DateTime.now().difference(lastFetchDate) > cpicMaxCacheTime;
}