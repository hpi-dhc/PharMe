import 'dart:io';

Future<bool> hasConnectionTo(String host) async {
  try {
    final result = await InternetAddress.lookup(host);
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
