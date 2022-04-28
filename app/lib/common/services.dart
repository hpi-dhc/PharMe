import 'package:hive_flutter/hive_flutter.dart';

import '../profile/models/hive/cpic_lookup_response.dart';
import '../profile/models/hive/diplotype.dart';
import 'models/metadata.dart';
import 'models/userdata.dart';

Future<void> initServices() async {
  await _initHive();

  await _initMetaData();
  await _initUserData();
}

enum Boxes {
  lookups,
  lookupsLastFetch,
  alleles,
  preferences,
  metadata,
  userData,
}

Box<T> getBox<T>(Boxes type) => Hive.box<T>(type.toString());

Future<void> _initMetaData() async {
  Hive.registerAdapter(MetadataAdapter());
  // if user's metadata is not null, assign it's contents to the singleton
  await Hive.openBox<Metadata>(Boxes.metadata.toString());
  final metaData = getBox<Metadata>(Boxes.metadata);
  final m = metaData.get('data') ?? Metadata();
  MetadataContainer.instance.data = m;
}

Future<void> _initUserData() async {
  Hive.registerAdapter(UserDataAdapter());
  // if user's data is not null, assign it's contents to the singleton
  await Hive.openBox<UserData>(Boxes.userData.toString());
  final userData = getBox<UserData>(Boxes.userData);
  final u = userData.get('data') ?? UserData();
  UserdataContainer.instance.data = u;
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DiplotypeAdapter());
  Hive.registerAdapter(CpicLookupAdapter());

  await Hive.openBox<List<Lookup>>(Boxes.lookups.toString());
}
