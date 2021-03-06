import 'package:hive_flutter/hive_flutter.dart';

import 'models/medication/cached_medications.dart';
import 'models/module.dart';

Future<void> initServices() async {
  await Hive.initFlutter();

  await initMetaData();
  await initUserData();
  await initCachedMedications();
}

Future<void> cleanupServices() async {
  await MetaData.save();
  await UserData.save();

  await CachedMedications.save();
}
