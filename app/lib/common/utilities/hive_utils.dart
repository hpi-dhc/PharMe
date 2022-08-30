import 'dart:convert';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

// TODO The D4L SDK depends on an older version of tink (1.2, but up to 1.4 in testing)
//      while flutter_secure_storage depends on 1.5.  This causes problems, so
//      use a dummy key here until someone figures out what to do
Future<List<int>> retrieveExistingOrGenerateKey() async {
  return List.filled(32, 0);
  // const secureStorage = FlutterSecureStorage();
  // if key not exists return null
  // final encryprionKey = await secureStorage.read(key: 'key');
  // if (encryprionKey == null) {
  //   final key = Hive.generateSecureKey();
  //   await secureStorage.write(
  //     key: 'key',
  //     value: base64UrlEncode(key),
  //   );
  // }
  // final key = Hive.generateSecureKey();// await secureStorage.read(key: 'key');
  // return key; // base64Url.decode(key);
}
