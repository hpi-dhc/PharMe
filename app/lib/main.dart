import 'common/module.dart';

Future<void> main() async {
  await initServices();
  await fetchAndSaveLookups();
  runApp(PharMeApp());
  await cleanupServices();
}
