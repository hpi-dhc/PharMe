import 'package:hive_flutter/hive_flutter.dart';

import 'models/metadata.dart';
import 'models/userdata.dart';

Future<void> initServices() async {
  await _initHive();

  await initMetaData();
  await initUserData();
}

Future<void> _initHive() async {
  await Hive.initFlutter();
}

Future<void> cleanupServices() async {
  await MetadataContainer.save();
  await UserData.save();
}
