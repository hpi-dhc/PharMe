import 'package:hive/hive.dart';

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
