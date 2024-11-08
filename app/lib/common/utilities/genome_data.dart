import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart';

import '../module.dart';

Future<void> saveDiplotypesAndActiveDrugs(
  List<LabResult> labData,
  List<String> activeDrugList,
  ActiveDrugs activeDrugs,
) async {
  UserData.instance.labData = labData;
  await UserData.save();
  await activeDrugs.setList(activeDrugList);
}

String formatLookupMapKey(String gene, String variant) {
  return '${gene}__$variant';
}

@visibleForTesting
Map<String, GenotypeResult> initializeGenotypeResultKeys() {
  final emptyGenotypeResults = <String, GenotypeResult>{};
  for (final drug in DrugsWithGuidelines.instance.drugs ?? <Drug>[]) {
    for (final guideline in drug.guidelines) {
      for (final gene in guideline.lookupkey.keys) {
        for (final variant in guideline.lookupkey[gene]!) {
          final skipLookup = variant == SpecialLookup.anyNotHandled.value ||
            variant == SpecialLookup.noResult.value;
          if (skipLookup) continue;
          final currentGenotypeKey = GenotypeKey(gene, variant);
          final variantIsRelevant = definedNonUniqueGenes.contains(gene);
          emptyGenotypeResults[currentGenotypeKey.value] =
            GenotypeResult.missingResult(
              gene,
              variant: variantIsRelevant ? currentGenotypeKey.allele : null,
              lookupkey: SpecialLookup.noResult.value,
            );
        }
      }
    }
  }
  return emptyGenotypeResults;
}

Future<void> maybeUpdateGenotypeResults() async {
  final skipUpdate = !shouldUpdateGenotypeResults();
  if (skipUpdate) return;

  final genotypeResults = initializeGenotypeResultKeys();

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

  for (final labResult in UserData.instance.labData ?? []) {
    final lookupMapKey = formatLookupMapKey(labResult.gene, labResult.variant);
    final lookup = lookupsHashMap[lookupMapKey];
    final genotypeResult = GenotypeResult.fromGenotypeData(labResult, lookup);
    if (!genotypeResults.keys.contains(genotypeResult.key.value)) continue;
    genotypeResults[genotypeResult.key.value] = genotypeResult;
  }
  UserData.instance.genotypeResults = genotypeResults;
  await UserData.save();

  // Save datetime at which lookups were fetched
  MetaData.instance.lookupsLastFetchDate = DateTime.now();
  await MetaData.save();
}

bool shouldUpdateGenotypeResults() {
  final genotypeResultsMissing =
    UserData.instance.genotypeResults?.isEmpty ?? true;
  final lookupsAreOutdated = MetaData.instance.lookupsLastFetchDate == null ||
    DateTime.now().difference(MetaData.instance.lookupsLastFetchDate!) >
      cpicMaxCacheTime;
  final labDataPresent = UserData.instance.labData?.isNotEmpty ?? false;
  final drugsWithGuidelinesPresent =
    DrugsWithGuidelines.instance.drugs?.isNotEmpty ?? false;
  return labDataPresent &&
    drugsWithGuidelinesPresent &&
    (genotypeResultsMissing || lookupsAreOutdated);
}

bool shouldFetchDiplotypes() {
  return UserData.instance.labData == null;
}
