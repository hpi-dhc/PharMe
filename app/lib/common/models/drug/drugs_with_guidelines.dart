import 'package:hive/hive.dart';

import '../../utilities/hive_utils.dart';
import '../module.dart';

part 'drugs_with_guidelines.g.dart';

const _boxName = 'DrugsWithGuidelines';

@HiveType(typeId: 5)
class DrugsWithGuidelines {
  factory DrugsWithGuidelines() => _instance;

  // private constructor
  DrugsWithGuidelines._();

  static DrugsWithGuidelines _instance = DrugsWithGuidelines._();
  static DrugsWithGuidelines get instance => _instance;

  /// Writes the current instance to local storage
  static Future<void> save() async =>
      Hive.box<DrugsWithGuidelines>(_boxName).put('data', _instance);

  static Future<void> erase() async {
    _instance = DrugsWithGuidelines._();
    await DrugsWithGuidelines.save();
  }

  @HiveField(0)
  int? version;

  @HiveField(1)
  List<Drug>? drugs;
}

Future<void> initDrugsWithGuidelines() async {
  try {
    Hive.registerAdapter(DrugsWithGuidelinesAdapter());
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
  await Hive.openBox<DrugsWithGuidelines>(
    _boxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  final drugsWithGuidelines = Hive.box<DrugsWithGuidelines>(_boxName);
  DrugsWithGuidelines._instance =
    drugsWithGuidelines.get('data') ?? DrugsWithGuidelines();
}
