import 'dart:io';

import '../module.dart';

Future<bool> hasConnectionTo(String host) async {
  try {
    final result = await InternetAddress.lookup(host);
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

// Replace whole stack, see https://stackoverflow.com/a/73784156
Future<void> overwriteRoutes(
  BuildContext context,
  { required PageRouteInfo nextPage }
) async {
  await context.router.pushAndPopUntil(
    nextPage,
    predicate: (_) => false
  );
}
