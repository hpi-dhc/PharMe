# Contributing

Please also see the [contribution guide in the root folder](../CONTRIBUTING.md).

## Local Setup

- Install [<img alt="flutter-logo"
  src="https://user-images.githubusercontent.com/82543715/142913349-54aafb75-8938-4299-b308-ecd2c4a226e7.png"
  width="16" height="16"> Flutter](https://flutter.dev/docs/get-started/install)
- Open a terminal in VSCode in the `app` directory
  - Run `dart pub get` to fetch all dart dependencies
  - Run `flutter pub get` to fetch all flutter dependencies and setup all
    generated code
  - Run `dart run build_runner build --delete-conflicting-outputs` or
    `dart run build_runner watch --delete-conflicting-outputs` to
    re-generate code upon file changes while developing

You should now be able to run the app by opening the debug panel on the left and
pressing the green triangle at the top (or using the shortcut <kbd>F5</kbd>).

## Useful Shortcuts

For (cleaning) generated code, you might want to add the following aliases to
your shell configuration:

```bash
alias flutter-generate='dart run build_runner build --delete-conflicting-outputs'
alias flutter-clean='find . -maxdepth 20 -type f \( -name "*.inject.summary" -o -name "*.inject.dart" -o  -name "*.g.dart" \) -delete'
```

## Architecture

The app consists of multiple so-called modules. Our main modules (usually app
screens) correspond to the direct subfolders of `lib/`.

Common functions used by modules such as `models`, `widgets`, and `utilities`
are living in `common`. All such functions are exported from
`common/module.dart`.

The structure of an example module `lib/my_module` should look as follows:

- `my_module`
  - `module.dart` (see example below):
    - exports everything that is required by other modules, i.e., page(s) and
      possibly the cubit
    - declares all routes as functions reeturning `AutoRoute`
    - may contain initialization code (`initMyModule()`)
  - `widgets`:
    - `my_widget.dart`: contains `MyWidget` and helpers
  - `pages`:
    - `my_module.dart`: contains `MyModulePage` and helpers
    - `my_child_page.dart`: contains
    - `my_complex_page`: create a folder for complex pages (e.g., tabbed ones);
      might want to create an own module if getting too complex
  - `utils.dart`: contains utilities used throughout this module
  - `cubit.dart`: contains `MyModuleCubit` and `MyModuleState`s (if needed)

Example for `my_module/module.dart`; the page is used as a root page in the tab
router, which is why the empty router `MyModuleRootPage` and adding
`AutoRoute(path: '', page: MyModuleRoute.page)` to children is needed.

```dart
import '../common/module.dart';

// For generated routes
export 'cubit.dart';
export 'pages/my_module.dart';
export 'pages/my_child_page.dart';
export 'pages/my_complex_page/page.dart';

@RoutePage()      
class MyModuleRootPage extends AutoRouter {}

AutoRoute myChildRoute() => AutoRoute(
  path: 'my_child',
  page: MyChildRoute.page,
);
AutoRoute myComplexRoute() => AutoRoute(
  path: 'my_complex',
  page: MyComplexRoute.page,
);

AutoRoute myModuleRoute({ required List<AutoRoute> children }) => AutoRoute(
  path: 'my_module',
  page: MyModuleRootRoute.page,
  children: [
    AutoRoute(path: '', page: MyModuleRoute.page),
    ...children, // includes myChildRoute() and priva
  ],
);
```

## Making app icons

Add the icon as `assets/icon/icon.png` (configured in `pubspec.yaml`) and run

```shell
flutter pub run flutter_launcher_icons:main
```

This will generate icons for both iOS as well as Android.

## Updating screenshots

🙅 _Not working yet due to login redirect, but keeping script for Sinai_
_version (login without redirect)._

To update the screenshots in `../docs/screenshots`
(used in [📑 App screens](../docs/App-screens.md),
[📑 User instructions](../docs/User-instructions.html), and the
[README](./README.md)), run the following command after adding username and
password to:

```shell
flutter drive \
  --driver=generate_screenshots/test_driver.dart \
  --target=generate_screenshots/app_test.dart \
  --dart-define=TEST_USER=<USERNAME> \
  --dart-define=TEST_PASSWORD=<PASSWORD>
```

If the error `The following MissingPluginException was thrown running a test:
MissingPluginException(No implementation found for method captureScreenshot on
channel plugins.flutter.io/integration_test)` occurs, the registration in the
file
`ios/.symlinks/plugins/integration_test/ios/Classes/IntegrationTestPlugin.m`
needs to be adapted (see
[issue](https://github.com/flutter/flutter/issues/91668)):

```m
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [[IntegrationTestPlugin instance] setupChannels:registrar.messenger];
}
```
