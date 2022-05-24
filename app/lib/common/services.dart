import 'package:hive_flutter/hive_flutter.dart';

import 'models/cached_reports.dart';
import 'models/module.dart';

Future<void> initServices() async {
  await Hive.initFlutter();

  await initMetaData();
  await initUserData();
  await initCachedReports();
}

Future<void> cleanupServices() async {
  await MetaData.save();
  await UserData.save();
  await CachedReports.save();
}
