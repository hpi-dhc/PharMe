import 'package:provider/provider.dart';

import 'common/module.dart';

Future<void> main() async {
  await initServices();
  await fetchAndSaveLookups();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ActiveDrugs(),
      child: PharMeApp(),
    ),
  );
  await cleanupServices();
}
