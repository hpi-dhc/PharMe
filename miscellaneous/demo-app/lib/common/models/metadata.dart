import 'package:hive/hive.dart';

import '../utilities/hive_utils.dart';

part 'metadata.g.dart';

const _boxName = 'metadata';

/// MetaData is a singleton dataclass which contains various user-specific
/// preferences and datapoints. It is intended to be loaded from a hive box
/// once at app launch, from where it's contents can be modified by accessing
/// it's properties.
@HiveType(typeId: 4)
class MetaData {
  factory MetaData() => _instance;

  // private constructor
  MetaData._();

  static final MetaData _instance = MetaData._();
  static MetaData get instance => _instance;

  /// Writes the current instance to local storage
  static Future<void> save() async =>
      Hive.box<MetaData>(_boxName).put('data', _instance);

  static Future<void> clearBox() async => Hive.box<MetaData>(_boxName).clear();

  @HiveField(0)
  DateTime? lookupsLastFetchDate;

  @HiveField(1)
  bool? isLoggedIn;
}

/// Initializes the user's metadata by registering all necessary adapters and
/// loading pre-existing data from local storage, if it exists.
Future<void> initMetaData() async {
  // We only want to register the adapter once. If it has already been
  // registered, we return early as to avoid overwriting changed data from the
  // session which has not yet been written to local storage.
  try {
    Hive.registerAdapter(MetaDataAdapter());
  } catch (e) {
    return;
  }

  final encryptionKey = await retrieveExistingOrGenerateKey();
  // if user's metadata is not null, assign it's contents to the singleton
  await Hive.openBox<MetaData>(
    _boxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  final metaData = Hive.box<MetaData>(_boxName);
  metaData.get('data') ?? MetaData();
}
