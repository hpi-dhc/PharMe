import 'dart:io';

Future<bool> hasConnectionTo(String host) async {
  try {
    final result = await InternetAddress.lookup('10.0.2.2:3000');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
