// Create screenshots from integration tests; from
// https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k

import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  try {
    await integrationDriver(
      onScreenshot: (screenshotName, screenshotBytes) async {
        final image =
          await File(
            '../docs/screenshots/$screenshotName.png'
          ).create(recursive: true);
        image.writeAsBytesSync(screenshotBytes);
        return true;
      },
    );
  } catch (e) {
    // ignore: avoid_print
    print('Error occured: $e');
  }
}