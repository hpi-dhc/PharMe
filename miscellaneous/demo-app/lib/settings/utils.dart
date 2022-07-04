import 'package:path_provider/path_provider.dart';

import '../common/models/medication/cached_medications.dart';
import '../common/module.dart';

Future<void> deleteAllAppData() async {
  await MetaData.clearBox();
  await UserData.clearBox();
  await CachedMedications.clearBox();
  // await _deleteCacheDir();
  // await _deleteAppDir();
}

Future<void> _deleteCacheDir() async {
  final tempDir = await getTemporaryDirectory();
  if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
}

Future<void> _deleteAppDir() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  if (appDocDir.existsSync()) appDocDir.deleteSync(recursive: true);
}
