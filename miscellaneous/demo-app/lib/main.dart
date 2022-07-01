import 'common/module.dart';

Future<void> main() async {
  await initServices();
  runApp(PharmeApp());
  await cleanupServices();
}
