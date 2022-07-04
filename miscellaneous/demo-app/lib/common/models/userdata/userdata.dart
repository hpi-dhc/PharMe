import 'package:hive/hive.dart';

import '../../utilities/hive_utils.dart';
import '../cpic_lookup_response.dart';
import 'diplotype.dart';

part 'userdata.g.dart';

const _boxName = 'userdata';

/// UserData is a singleton data-class which contains various user-specific
/// data It is intended to be loaded from a Hive box once at app launch, from
/// where it's contents can be modified by accessing it's properties.
@HiveType(typeId: 5)
class UserData {
  factory UserData() => _instance;

  // private constructor
  UserData._();

  static final UserData _instance = UserData._();
  static UserData get instance => _instance;

  /// Writes the current instance to local storage
  static Future<void> save() async =>
      Hive.box<UserData>(_boxName).put('data', _instance);

  static Future<void> deleteFromDisk() async =>
      Hive.box<UserData>(_boxName).deleteFromDisk();

  @HiveField(0)
  List<Diplotype>? diplotypes;

  @HiveField(1)
  Map<String, String>? lookups;
}

/// Initializes the user's data by registering all necessary adapters and
/// loading pre-existing data from local storage, if it exists.
Future<void> initUserData() async {
  // We only want to register the necessary adapters once. If it has already been
  // registered, we return early as to avoid overwriting changed data from the
  // session which has not yet been written to local storage.
  try {
    Hive.registerAdapter(UserDataAdapter());
    Hive.registerAdapter(DiplotypeAdapter());
    Hive.registerAdapter(CpicLookupAdapter());
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
  userData.get('data') ?? UserData();
}

Future<void> deleteBoFromDisk() async {
  final encryptionKey = await retrieveExistingOrGenerateKey();
  final box = await Hive.openBox<UserData>(_boxName,
      encryptionCipher: HiveAesCipher(encryptionKey));
  await box.deleteFromDisk();
}
