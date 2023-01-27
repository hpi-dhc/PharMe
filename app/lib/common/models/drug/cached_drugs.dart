import 'package:hive/hive.dart';

import '../module.dart';

part 'cached_drugs.g.dart';

const _boxName = 'cachedDrugs';

@HiveType(typeId: 13)
class CachedDrugs {
  factory CachedDrugs() => _instance;

  // private constructor
  CachedDrugs._();

  static CachedDrugs _instance = CachedDrugs._();
  static CachedDrugs get instance => _instance;

  /// Writes the current instance to local storage
  static Future<void> save() async =>
      Hive.box<CachedDrugs>(_boxName).put('data', _instance);

  @HiveField(0)
  int? version;

  @HiveField(1)
  List<Drug>? drugs;
}

Future<void> initCachedDrugs() async {
  try {
    Hive.registerAdapter(CachedDrugsAdapter());
    Hive.registerAdapter(DrugAdapter());
    Hive.registerAdapter(DrugAnnotationsAdapter());
    Hive.registerAdapter(GuidelineAdapter());
    Hive.registerAdapter(WarningLevelAdapter());
    Hive.registerAdapter(GuidelineAnnotationsAdapter());
    Hive.registerAdapter(GuidelineCpicDataAdapter());
  } catch (e) {
    return;
  }

  await Hive.openBox<CachedDrugs>(_boxName);
  final cachedDrugs = Hive.box<CachedDrugs>(_boxName);
  CachedDrugs._instance = cachedDrugs.get('data') ?? CachedDrugs();
}
