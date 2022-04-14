import 'package:hive_flutter/hive_flutter.dart';

import '../profile/models/hive/alleles.dart';
import '../profile/models/hive/cpic_lookup_response.dart';
import '../profile/models/hive/diplotype.dart';

Future<void> initServices() async {
  await _initHive();
}

enum Boxes {
  lookups,
  lookupsLastFetch,
  alleles,
  preferences,
}

Box<T> getBox<T>(Boxes type) {
  return Hive.box<T>(type.toString());
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AllelesAdapter());
  Hive.registerAdapter(DiplotypeAdapter());
  Hive.registerAdapter(CpicLookupAdapter());
  await Hive.openBox<List<Lookup>>(Boxes.lookups.toString());
  await Hive.openBox<DateTime>(Boxes.lookupsLastFetch.toString());
  await Hive.openBox<Alleles>(Boxes.alleles.toString());
  await Hive.openBox(Boxes.preferences.toString());
}
