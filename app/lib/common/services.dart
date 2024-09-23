import 'package:hive_flutter/hive_flutter.dart';

import 'module.dart';

Future<void> initServices() async {
  await Hive.initFlutter();

  await initMetaData();
  await initUserData();
  await initDrugsWithGuidelines();
  WidgetsFlutterBinding.ensureInitialized();
}

Future<void> cleanupServices() async {
  await MetaData.save();
  await UserData.save();

  await DrugsWithGuidelines.save();
}
