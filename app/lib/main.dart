import 'common/module.dart';

Future<void> main() async {
  await initServices();
  await fetchAndSaveLookups();
  await updateCachedDrugs();
  runApp(PharMeApp());
  await cleanupServices();
}
