import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../module.dart';

Future<List<int>> retrieveExistingOrGenerateKey() async {
  const secureStorage = FlutterSecureStorage();
  // if key not exists return null
  final encryptionKey = await secureStorage.read(key: 'key');
  if (encryptionKey == null) {
    final key = Hive.generateSecureKey();
    await secureStorage.write(
      key: 'key',
      value: base64UrlEncode(key),
    );
  }
  final key = await secureStorage.read(key: 'key');
  return base64Url.decode(key!);
}

Future<void> unsetAllData() async {
  await UserData.erase();
  await MetaData.erase();
  await DrugsWithGuidelines.erase();
}

Future<void> deleteAllAppData() async {
  await unsetAllData();
  await _deleteCacheDir();
  await _deleteAppDir();
}

// The folders themselves cannot be deleted on iOS, therefore delete all content
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

