import 'package:hive/hive.dart';

import '../../profile/models/hive/cpic_lookup_response.dart';
import '../../profile/models/hive/diplotype.dart';
import '../services.dart';

part 'userdata.g.dart';

/// UserdataContainer is a singleton which contains various user-specific data
/// It is intended to be loaded from a hive box once at app launch, from where
/// it's contents can be modified by accessing it's properties.
class UserdataContainer {
  factory UserdataContainer() => _instance;

  // private constructor
  UserdataContainer._(this.data);

  static Future<void> save() async {
    await getBox<UserData>(Boxes.userData).put('data', _instance.data);
  }

  static final UserdataContainer _instance = UserdataContainer._(UserData());

  static UserdataContainer get instance => _instance;

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
