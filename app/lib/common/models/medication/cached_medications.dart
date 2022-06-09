import 'package:hive/hive.dart';

import '../../constants.dart';
import '../../utilities/medication_utils.dart';
import '../module.dart';

part 'cached_medications.g.dart';

const _boxName = 'cachedMedications';

@HiveType(typeId: 13)
class CachedMedications {
  factory CachedMedications() => _instance;

  // private constructor
  CachedMedications._();

  static final CachedMedications _instance = CachedMedications._();
  static CachedMedications get instance => _instance;

  /// Writes the current instance to local storage
  static Future<void> save() async =>
      Hive.box<CachedMedications>(_boxName).put('data', _instance);

  /// Caches a list of medications along with their guidelines
  ///
  /// Internally calls cache on each medication seperately
  static Future<void> cacheAll(List<MedicationWithGuidelines> meds) async =>
      meds.forEach(cache);

  /// Caches a medications along with its guidelines
  static Future<void> cache(MedicationWithGuidelines med) async =>
      _cacheMedication(med);

  @HiveField(0)
  DateTime? lastFetch;

  @HiveField(1)
  List<MedicationWithGuidelines>? medications;
}

Future<void> initCachedMedications() async {
  try {
    Hive.registerAdapter(CachedMedicationsAdapter());
    Hive.registerAdapter(GeneSymbolAdapter());
    Hive.registerAdapter(PhenotypeAdapter());
    Hive.registerAdapter(GenePhenotypeAdapter());
    Hive.registerAdapter(GuidelineAdapter());
    Hive.registerAdapter(MedicationWithGuidelinesAdapter());
  } catch (e) {
    return;
  }

  await Hive.openBox<CachedMedications>(_boxName);
  final cachedMedications = Hive.box<CachedMedications>(_boxName);
  cachedMedications.get('data') ?? CachedMedications();
}

Future<void> _cacheMedication(MedicationWithGuidelines medication) async {
  CachedMedications.instance.medications ??= [];
  final cachedMedList = CachedMedications.instance.medications!;
  // only allow caching up to maxCachedMedications results
  if (cachedMedList.length >= maxCachedMedications) {
    return _cacheWhenLimitReached(cachedMedList, medication);
  }

  // equality for a medication is defined as same name and same value for the guidelines
  if (cachedMedList.contains(medication)) return;

  // if there is a medication with the same name already cached, then update its guidelines
  final index =
      cachedMedList.indexWhere((element) => element.name == medication.name);

  // index is negative if no match is found
  final medicationAlreadyExists = index >= 0;
  if (medicationAlreadyExists) {
    final filteredMedication = filterUserGuidelines(medication);
    cachedMedList[index] = filteredMedication;
    return CachedMedications.save();
  }
  // if the medication is completely new add to the list
  cachedMedList.add(medication);
  return CachedMedications.save();
}

Future<void> _cacheWhenLimitReached(
  List<MedicationWithGuidelines> cachedMedList,
  MedicationWithGuidelines med,
) async {
  // find first medication that's not used in the reports
  final index = cachedMedList.indexWhere((e) => !e.isCritical);
  if (index < 0) return;

  cachedMedList.removeAt(index);
  cachedMedList.add(med);
  return CachedMedications.save();
}
