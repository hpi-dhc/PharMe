import 'package:hive/hive.dart';
import '../../module.dart';
import '../../utilities/hive_utils.dart';

part 'userdata.g.dart';

const _boxName = 'userdata';

const overwritePhenotype = 'Poor Metabolizer';

/// UserData is a singleton data-class which contains various user-specific
/// data It is intended to be loaded from a Hive box once at app launch, from
/// where it's contents can be modified by accessing it's properties.
@HiveType(typeId: 3)
class UserData {
  factory UserData() => _instance;

  // private constructor
  UserData._();

  static UserData _instance = UserData._();
  static UserData get instance => _instance;

  /// Writes the current instance to local storage
  static Future<void> save() async =>
      Hive.box<UserData>(_boxName).put('data', _instance);

  static Future<void> erase() async {
    _instance = UserData._();
    await UserData.save();
  }

  @HiveField(0)
  List<LabResult>? labData;
  @HiveField(1)
  // hive can't deal with sets so we have to use a list :(
  List<String>? activeDrugNames;
  @HiveField(2)
  Map<String, GenotypeResult>? genotypeResults;

  static String? variantFor(String genotypeKey) =>
      UserData.instance.genotypeResults?[genotypeKey]?.variant;

  static String? allelesTestedFor(String genotypeKey) =>
      UserData.instance.genotypeResults?[genotypeKey]?.allelesTested;

  static String? lookupFor(
    String genotypeKey,
    {
      String? drug,
      bool useOverwrite = true,
    }
  ) {
    final overwrittenLookup =
      getOverwrittenLookup(genotypeKey, drug: drug);
    if (useOverwrite && overwrittenLookup != null) {
      return overwrittenLookup.value;
    }
    return UserData.instance.genotypeResults?[genotypeKey]?.lookupkey;
  }
}

// Wrapper of UserData.instance.activeDrugNames that manages changes; used to
// notify inactive tabs in case of changes. Should be refactored to ensure
// consistent use across the app, see
// https://github.com/hpi-dhc/PharMe/issues/680
class ActiveDrugs extends ChangeNotifier {
  ActiveDrugs() {
    names = UserData.instance.activeDrugNames ?? [];
  }
  late List<String> names;

  Future<void> _preserveAndNotify() async {
    UserData.instance.activeDrugNames = names;
    await UserData.save();
    notifyListeners();
  }

  Future<void> setList(List<String> drugNames) async {
    names = drugNames;
    await _preserveAndNotify();
  }

  Future<void> _add(String drugName) async {
    names.add(drugName);
    await _preserveAndNotify();
  }

  Future<void> _remove(String drugName) async {
    names = names.filter((name) => name != drugName).toList();
    await _preserveAndNotify();
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> changeActivity(String drugName, bool value) async {
    if (value) {
      await _add(drugName);
    } else {
      await _remove(drugName);
    }
  }

  bool contains(String drugName) {
    return names.contains(drugName);
  }

  bool isNotEmpty() {
    return names.isNotEmpty;
  }
}

/// Initializes the user's data by registering all necessary adapters and
/// loading pre-existing data from local storage, if it exists.
Future<void> initUserData() async {
  // We only want to register the necessary adapters once. If it has already been
  // registered, we return early as to avoid overwriting changed data from the
  // session which has not yet been written to local storage.
  try {
    Hive.registerAdapter(UserDataAdapter());
    Hive.registerAdapter(LabResultAdapter());
    Hive.registerAdapter(GenotypeResultAdapter());
  } catch (e) {
    return;
  }

  final encryptionKey = await retrieveExistingOrGenerateKey();
  // if user's metadata is not null, assign it's contents to the singleton
  await Hive.openBox<UserData>(
    _boxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  final userData = Hive.box<UserData>(_boxName);
  UserData._instance = userData.get('data') ?? UserData();
}
