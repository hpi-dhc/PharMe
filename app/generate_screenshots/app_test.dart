// Clicks though most parts of the app and creates screenshots; based on
// https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k

import 'dart:io';

import 'package:app/app.dart';
import 'package:app/common/module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

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

void logTimeStamp(String description) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  // ignore: avoid_print
  print('TIMESTAMP: $timestamp $description');
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

      // Part before runApp in lib/main.dart
      await initServices();
      await updateGenotypeResults();

      // Load the app
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ActiveDrugs(),
          child: PharMeApp(),
        ),
      );
      await tester.pumpAndSettle();

      logTimeStamp('test_start');

      // Click though the app and create screenshots

      // login
      await Future.delayed(Duration(seconds: 5)); // wait for logo & screencast
      await takeScreenshot(tester, binding, 'login');

      logTimeStamp('login');

      // login-redirect (not working; only taking screenshot of loading screen)
      // could try to use cubit function to directly sign in which will only
      // open the webview and close it again
      // await tester.tap(find.byType(FullWidthButton).first);
      // await Future.delayed(Duration(seconds: 3)); // wait for dialog
      // await takeScreenshot(tester, binding, 'login-redirect');

      // Part after runApp in lib/main.dart
      await cleanupServices();
    });
  });
}