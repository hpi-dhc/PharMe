import 'package:hive/hive.dart';

import '../../constants.dart';
import '../module.dart';

part 'cached_drugs.g.dart';

const _boxName = 'cachedDrugs';

@HiveType(typeId: 13)
class CachedDrugs {
  factory CachedDrugs() => _instance;

  // private constructor
  CachedDrugs._();

  static final CachedDrugs _instance = CachedDrugs._();
  static CachedDrugs get instance => _instance;

  /// Writes the current instance to local storage
  static Future<void> save() async =>
      Hive.box<CachedDrugs>(_boxName).put('data', _instance);

  /// Caches a list of drugs along with their guidelines
  ///
  /// Internally calls cache on each drug seperately
  static Future<void> cacheAll(List<Drug> meds) async =>
      meds.forEach(cache);

  /// Caches a drugs along with its guidelines
  static Future<void> cache(Drug med) async => _cacheDrug(med);

  @HiveField(0)
  DateTime? lastFetch;

  @HiveField(1)
  List<Drug>? drugs;
}

Future<void> initCachedDrugs() async {
  try {
    Hive.registerAdapter(CachedDrugsAdapter());
    Hive.registerAdapter(GeneSymbolAdapter());
    Hive.registerAdapter(GeneResultAdapter());
    Hive.registerAdapter(PhenotypeAdapter());
    Hive.registerAdapter(WarningLevelAdapter());
    Hive.registerAdapter(GuidelineAdapter());
    Hive.registerAdapter(DrugWithGuidelinesAdapter());
  } catch (e) {
    return;
  }

  await Hive.openBox<CachedDrugs>(_boxName);
  final cachedDrugs = Hive.box<CachedDrugs>(_boxName);
  cachedDrugs.get('data') ?? CachedDrugs();
}

Future<void> _cacheDrug(Drug drug) async {
  CachedDrugs.instance.drugs ??= [];
  final cachedMedList = CachedDrugs.instance.drugs!;
  // only allow caching up to maxCachedDrugs results
  if (cachedMedList.length >= maxCachedDrugs) {
    return _cacheWhenLimitReached(cachedMedList, drug);
  }

  // equality for a drug is defined as same name and same value for the guidelines
  if (cachedMedList.contains(drug)) return;

  // if there is a drug with the same name already cached, then update its guidelines
  final index =
      cachedMedList.indexWhere((element) => element.name == drug.name);

  // index is negative if no match is found
  final drugAlreadyExists = index >= 0;
  if (drugAlreadyExists) {
    final filteredDrug = drug.filterUserGuidelines();
    cachedMedList[index] = filteredDrug;
    return CachedDrugs.save();
  }
  // if the drug is completely new add to the list
  cachedMedList.add(drug);
  return CachedDrugs.save();
}

Future<void> _cacheWhenLimitReached(
  List<Drug> cachedMedList,
  Drug med,
) async {
  // find first drug that's not used in the reports
  final index = cachedMedList.indexWhere((drug) =>
      !(UserData.instance.starredMediationIds ?? []).contains(drug.id));
  if (index < 0) return;

  cachedMedList.removeAt(index);
  cachedMedList.add(med);
  return CachedDrugs.save();
}
