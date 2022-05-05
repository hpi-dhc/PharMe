import 'common/module.dart';
import 'common/services.dart';
import 'common/utilities/genome_data.dart';

Future<void> main() async {
  await initServices();
  await fetchAndSaveLookups();
  runApp(PharmeApp());
  await cleanupServices();
}
