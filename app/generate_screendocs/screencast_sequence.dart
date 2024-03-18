// Clicks though most parts of the app and outputs timestamp logs for cutting
// smaller screencasts in generate_screencast.sh script

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'sequence_utils.dart';

void logTimeStamp(String prefix, String description) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  // ignore: avoid_print
  print('$prefix$timestamp $description');
}

void main() {
  group('click through the app and create screenshots', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets('take screencast', (tester) async {
      // ignore: unused_local_variable
      const username = String.fromEnvironment('TEST_USER');
      // ignore: unused_local_variable
      const password = String.fromEnvironment('TEST_PASSWORD');
      const timestampPrefix = String.fromEnvironment('TIMESTAMP_PREFIX');
      // ignore: unused_local_variable
      const startOffset = int.fromEnvironment('START_OFFSET');

      await loadApp(tester);

      // login
      logTimeStamp(timestampPrefix, 'login');
      await wait(5);
      logTimeStamp(timestampPrefix, 'login');

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