import 'package:hive/hive.dart';

import '../../utilities/hive_utils.dart';
import '../module.dart';

part 'cached_drugs.g.dart';

const _boxName = 'cachedDrugs';

@HiveType(typeId: 5)
class CachedDrugs {
  factory CachedDrugs() => _instance;

  // private constructor
  CachedDrugs._();

  static CachedDrugs _instance = CachedDrugs._();
  static CachedDrugs get instance => _instance;

  /// Writes the current instance to local storage
  static Future<void> save() async =>
      Hive.box<CachedDrugs>(_boxName).put('data', _instance);

  static Future<void> erase() async {
    _instance = CachedDrugs._();
    await CachedDrugs.save();
  }

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
    Hive.registerAdapter(GuidelineExtDataAdapter());
  } catch (e) {
    return;
  }

  // cached drugs have exactly the matching guidelines saved, i.e. they can be
  // used to figure out the user's gene lookupkeys, i.e. we have to encrypt.
  final encryptionKey = await retrieveExistingOrGenerateKey();
  await Hive.openBox<CachedDrugs>(
    _boxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  final cachedDrugs = Hive.box<CachedDrugs>(_boxName);
  CachedDrugs._instance = cachedDrugs.get('data') ?? CachedDrugs();
}

extension CachedDrugsMethods on CachedDrugs {
  Set<String> get allGuidelineGenes {
    final guidelineGenes = <String>{};
    if (CachedDrugs.instance.drugs != null) {
      for (final drug in CachedDrugs.instance.drugs!) {
        for (final guideline in drug.guidelines) {
          guideline.lookupkey.keys.forEach(guidelineGenes.add);
        }
      }
    }
    return guidelineGenes;
  }
}