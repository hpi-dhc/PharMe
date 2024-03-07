// Clicks though most parts of the app and creates screenshots; based on
// https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app_sequence_utils.dart';

Future<void> takeScreenshot(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String fileName
) async {
  if (Platform.isAndroid) {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  }
  await binding.takeScreenshot(fileName);
}

void main() {
  group('click through the app and create screenshots', () {
    final binding = IntegrationTestWidgetsFlutterBinding();
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets('take screenshots', (tester) async {
      // ignore: unused_local_variable
      const username = String.fromEnvironment('TEST_USER');
      // ignore: unused_local_variable
      const password = String.fromEnvironment('TEST_PASSWORD');

      await loadApp(tester);

      // login
      await wait(5); // wait for logo
      await takeScreenshot(tester, binding, 'login');

      // login-redirect (not working; only taking screenshot of loading screen)
      // could try to use cubit function to directly sign in which will only
      // open the webview and close it again
      // await tester.tap(find.byType(FullWidthButton).first);
      // await Future.delayed(Duration(seconds: 3)); // wait for dialog
      // await takeScreenshot(tester, binding, 'login-redirect');

      await cleanupApp();
    });
  });
}