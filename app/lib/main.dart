import 'common/module.dart';

Future<void> main() async {
  await initServices();
  await fetchAndSaveLookups();
  try {
    await updateCachedDrugs();
    // ignore: empty_catches
  } catch (error) {}
  runApp(PharMeApp());
  await cleanupServices();
}
