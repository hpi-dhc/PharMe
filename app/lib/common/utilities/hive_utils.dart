// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
