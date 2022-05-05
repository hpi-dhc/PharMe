import 'common/module.dart';
import 'common/services.dart';

Future<void> main() async {
  await initServices();
  runApp(PharmeApp());
  await cleanupServices();
}
