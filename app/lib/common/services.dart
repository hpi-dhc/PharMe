import 'package:hive_flutter/hive_flutter.dart';

import '../profile/models/hive/alleles.dart';
import '../profile/models/hive/cpic_lookup_response.dart';
import '../profile/models/hive/diplotype.dart';

Future<void> initServices() async {
  await _initHive();
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AllelesAdapter());
  Hive.registerAdapter(DiplotypeAdapter());
  Hive.registerAdapter(CpicLookupAdapter());
  await Hive.openBox('userData');
  await Hive.openBox('preferences');
}
