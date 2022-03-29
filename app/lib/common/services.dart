import 'package:hive_flutter/hive_flutter.dart';

import '../profile/models/hive/alleles.dart';
import '../profile/models/hive/diplotype.dart';

Future<void> initServices() async {
  await _initHive();
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AllelesAdapter());
  Hive.registerAdapter(DiplotypeAdapter());
  await Hive.openBox<Alleles>('userData');
  await Hive.openBox('preferences');
}
