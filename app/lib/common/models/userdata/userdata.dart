import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

import '../../../search/module.dart';
import '../../utilities/hive_utils.dart';

part 'userdata.g.dart';

const _boxName = 'userdata';

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
  Map<String, Diplotype>? diplotypes;
  static String? phenotypeFor(String gene) =>
      UserData.instance.diplotypes?[gene]?.phenotype;

  @HiveField(1)
  Map<String, CpicPhenotype>? lookups;

  static MapEntry<String, String>? overwrittenLookup(String gene) {
    final inhibitors = drugInhibitors[gene];
    if (inhibitors == null) return null;
    final lookup = inhibitors.entries.firstWhereOrNull((entry) =>
        UserData.instance.activeDrugNames?.contains(entry.key) ?? false);
    if (lookup == null) return null;
    return lookup;
  }

  static String? lookupFor(String gene) {
    final overwrittenLookup = UserData.overwrittenLookup(gene);
    if (overwrittenLookup != null) {
      return overwrittenLookup.value;
    }
    return UserData.instance.lookups?[gene]?.lookupkey;
  }

  // hive can't deal with sets so we have to use a list :(
  @HiveField(2)
  List<String>? activeDrugNames;
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
    Hive.registerAdapter(CpicPhenotypeAdapter());
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

// assumes http reponse from lab server
List<String> activeDrugsFromHTTPResponse(Response resp) {
  final activeDrugs = jsonDecode(resp.body)['medications'] as List<dynamic>;
  return List<String>.from(activeDrugs);
}
