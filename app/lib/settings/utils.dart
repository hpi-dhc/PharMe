import 'package:path_provider/path_provider.dart';

Future<void> deleteAllAppData() async {
  await _deleteCacheDir();
  await _deleteAppDir();
}

Future<void> _deleteCacheDir() async {
  final tempDir = await getTemporaryDirectory();
  if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
}

Future<void> _deleteAppDir() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  if (appDocDir.existsSync()) appDocDir.deleteSync(recursive: true);
}
