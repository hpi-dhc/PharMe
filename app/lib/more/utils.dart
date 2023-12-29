import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../common/module.dart';

Future<void> deleteAllAppData() async {
  await _deleteCacheDir();
  await _deleteAppDir();
  await UserData.erase();
  await MetaData.erase();
  await CachedDrugs.erase();
}

// The folders themself cannot be deleted on iOS, therefore delete all content
// inside the folders
void _deleteFolderContent(Directory directory) {
  if (!directory.existsSync()) return;
  for (final item in directory.listSync()) {
    item.deleteSync(recursive: true);
  }
}

Future<void> _deleteCacheDir() async {
  final tempDir = await getTemporaryDirectory();
  _deleteFolderContent(tempDir);
}

Future<void> _deleteAppDir() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  _deleteFolderContent(appDocDir);
}
