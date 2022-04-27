import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart';

import '../../profile/models/hive/alleles.dart';
import '../../profile/models/hive/cpic_lookup_response.dart';
import '../../profile/models/hive/diplotype.dart';
import '../constants.dart';
import '../models/metadata.dart';
import '../models/userdata.dart';
import '../services.dart';

Future<void> fetchAndSaveAllesData(String token, String url) async {
  final userAlleleData = UserdataContainer.instance.data.alleles;
  if (userAlleleData == null) {
    final response = await getStarAlleles(token, url);
    if (response.statusCode == 200) {
      await _saveAlleleData(response);
    } else {
      throw Exception('Error occurred during loading of allele data');
    }
  }
}

Future<Response> getStarAlleles(String? token, String url) async {
  return get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
}

Future<void> _saveAlleleData(Response response) async {
  final alleles = Alleles.fromJson(jsonDecode(response.body));
  alleles.diplotypes = alleles.diplotypes.filterValidDiplotypes();

  UserdataContainer.instance.data.alleles = alleles;
  return UserdataContainer.save();
}

Future<void> fetchAndSaveLookups() async {
  if (!shouldFetchLookups()) return;
  final response = await get(Uri.parse(cpicLookupUrl));
  if (response.statusCode != 200) {
    throw Exception();
  }

  // the returned json is a list of lookups which we wish to individually map
  // to a concrete CpicLookup instance, hence the cast to a List
  final json = jsonDecode(response.body) as List<dynamic>;
  final lookups =
      json.map<CpicLookup>(CpicLookup.fromJson).filterValidLookups();
  final usersAlleles = UserdataContainer.instance.data.alleles;
  if (usersAlleles == null) {
    throw Exception();
  }

  // use a HashMap for better time complexity
  final lookupsHashMap = HashMap<String, Lookup>.fromIterable(
    lookups,
    key: (el) => '${el.genesymbol}${el.diplotype}',
    value: (el) => el.lookupkey,
  );
  // ignore: omit_local_variable_types
  final List<Lookup> matchingLookups = [];
  // extract the matching lookups
  for (final diplotype in usersAlleles.diplotypes) {
    // the gene and the genotype build the key for the hashmap
    final temp = lookupsHashMap['${diplotype.gene}${diplotype.genotype}'];
    if (temp != null) matchingLookups.add(temp);
  }

  UserdataContainer.instance.data.lookups = matchingLookups;
  await UserdataContainer.save();

  // Save datetime at which lookups were fetched
  MetadataContainer.instance.data.lookupsLastFetchDate = DateTime.now();
  await MetadataContainer.save();
}

bool shouldFetchLookups() {
  final lookupsPresent = UserdataContainer.instance.data.lookups?.isNotEmpty;
  return _isOutDated() || (lookupsPresent ?? false);
}

bool _isOutDated() {
  final lastFetchDate = MetadataContainer.instance.data.lookupsLastFetchDate;
  if (lastFetchDate == null) {
    return true;
  }
  return DateTime.now().difference(lastFetchDate) > cpicMaxCacheTime;
}
