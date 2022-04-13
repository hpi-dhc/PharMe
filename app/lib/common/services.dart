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

String box(Boxes boxType) {
  switch(boxType) {
    case Boxes.lookups:
      return 'lookups';
    case Boxes.lookupsLastFetch:
      return 'lookupsLastFetch';
    case Boxes.alleles:
      return 'alleles';
    case Boxes.preferences:
      return 'preferences';
  }
}


Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AllelesAdapter());
  Hive.registerAdapter(DiplotypeAdapter());
  Hive.registerAdapter(CpicLookupAdapter());
  await Hive.openBox<List<Lookup>>(box(Boxes.lookups));
  await Hive.openBox<DateTime>(box(Boxes.lookupsLastFetch));
  await Hive.openBox<Alleles>(box(Boxes.alleles));
  await Hive.openBox(box(Boxes.preferences));
}
