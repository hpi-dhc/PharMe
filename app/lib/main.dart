import 'package:provider/provider.dart';

import 'app.dart';
import 'common/module.dart';

Future<void> main() async {
  await initServices();
  // Maybe refresh lookups on app start
  await fetchAndSaveLookups();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ActiveDrugs(),
      child: PharMeApp(),
    ),
  );
  await cleanupServices();
}
