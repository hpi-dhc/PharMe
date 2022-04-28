import 'package:hive/hive.dart';

import '../../profile/models/hive/cpic_lookup_response.dart';
import '../../profile/models/hive/diplotype.dart';

part 'userdata.g.dart';

const _boxName = 'userdata';

/// UserdataContainer is a singleton data-class which contains various
/// user-specific data It is intended to be loaded from a Hive box once at app
/// launch, from where it's contents can be modified by accessing it's
/// properties.
class UserdataContainer {
  factory UserdataContainer() => _instance;

  // private constructor
  UserdataContainer._(this.data);

  static final UserdataContainer _instance = UserdataContainer._(UserData());
  static UserdataContainer get instance => _instance;

  /// Writes the current state of `data` to local storage
  static Future<void> save() async =>
      Hive.box<UserData>(_boxName).put('data', _instance.data);

  UserData data;
}

@HiveType(typeId: 5)
class UserData {
  UserData({
    this.diplotypes,
    this.lookups,
  });

  @HiveField(0)
  List<Diplotype>? diplotypes;

  @HiveField(1)
  List<Lookup>? lookups;
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
  // if user's metadata is not null, assign it's contents to the singleton
  await Hive.openBox<UserData>(_boxName);
  final userData = Hive.box<UserData>(_boxName);
  final sessionData = userData.get('data') ?? UserData();
  UserdataContainer.instance.data = sessionData;
}
