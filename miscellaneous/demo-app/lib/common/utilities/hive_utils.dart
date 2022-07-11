import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

Future<List<int>> retrieveExistingOrGenerateKey() async {
  const secureStorage = FlutterSecureStorage();
  // if key not exists return null
  final encryprionKey = await secureStorage.read(key: 'key');
  if (encryprionKey == null) {
    final key = Hive.generateSecureKey();
    await secureStorage.write(
      key: 'key',
      value: base64UrlEncode(key),
    );
  }
  final key = await secureStorage.read(key: 'key');
  return base64Url.decode(key!);
}
