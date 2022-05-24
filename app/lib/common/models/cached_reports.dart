import 'package:hive/hive.dart';

import '../module.dart';

part 'cached_reports.g.dart';

const _boxName = 'cachedReports';

@HiveType(typeId: 6)
class CachedReports {
  factory CachedReports() => _instance;

  // private constructor
  CachedReports._();

  static final CachedReports _instance = CachedReports._();
  static CachedReports get instance => _instance;

  /// Writes the current instance to local storage
  static Future<void> save() async =>
      Hive.box<CachedReports>(_boxName).put('data', _instance);

  @HiveField(0)
  DateTime? lastFetch;

  @HiveField(1)
  List<MedicationWithGuidelines>? medications;
}

Future<void> initCachedReports() async {
  try {
    Hive.registerAdapter(CachedReportsAdapter());
    Hive.registerAdapter(GeneSymbolAdapter());
    Hive.registerAdapter(PhenotypeAdapter());
    Hive.registerAdapter(GenePhenotypeAdapter());
    Hive.registerAdapter(GuidelineAdapter());
    Hive.registerAdapter(MedicationWithGuidelinesAdapter());
  } catch (e) {
    return;
  }

  await Hive.openBox<CachedReports>(_boxName);
  final cachedReports = Hive.box<CachedReports>(_boxName);
  cachedReports.get('data') ?? CachedReports();
}
