# Contributing

Please also see the [contribution guide in the root folder](../CONTRIBUTING.md).

## Local Setup

- Install [<img
  src="https://user-images.githubusercontent.com/82543715/142913349-54aafb75-8938-4299-b308-ecd2c4a226e7.png"
  width="16" height="16"> Flutter](https://flutter.dev/docs/get-started/install)
- Open a terminal in VSCode in the `app` directory
  - Run `dart pub get` to fetch all dart dependencies
  - Run `flutter pub get` to fetch all flutter dependencies and setup all
    generated code
  - Run `flutter pub run build_runner build --delete-conflicting-outputs`

You should now be able to run the app by opening the debug panel on the left and
pressing the green triangle at the top (or using the shortcut <kbd>F5</kbd>).

## Architecture

The app consists of multiple so-called modules. Our main modules correspond to
the direct subfolders of `lib/`.

### Example Module

Structure of `lib/my_module`:

- `my_module`
  - `module.dart`:
    - exports everything that is required by other modules
    - declares all routes as a const variable (`myModuleRoutes`)
    - may contain initialization code (`initMyModule()`)
  - `cubit.dart`: contains `MyModuleCubit` and `MyModuleState`s
  - `widgets`:
    - `my_widget.dart`: contains `MyWidget` and helpers
  - `pages`:
    - `my_first.dart`: contains `MyFirstPage` and helpers
    - `my_complex`: create a folder for complex pages (e.g., tabbed ones)
      - `page.dart`: contains `MyComplexPage`
      - `tab_first.dart`: contains `FirstTab` and helpers
      - `tab_second.dart`: contains `SecondTab` and helpers
      - `utils.dart`: contains utilities used by multiple files in this page
  - `utils.dart`: contains utilities used throughout this module
  - `submodule_one`
  - `submodule_two`

If a single file gets too complex for routes, the `Cubit`, a widget, a page,
etc., you can create a folder with the same name and split the original file
into different files. An example of that is `MyComplexPage` in the file tree
above.

## Making app icons

Add the icon as `assets/icon/icon.png` (configured in `pubspec.yaml`) and run

```shell
flutter pub run flutter_launcher_icons:main
```

This will generate icons for both iOS as well as Android.

## Building with Docker for Android

Using `instrumentisto/flutter` to build (of course also possible locally, but
might not work due to conflicting Java/Gradle/... versions).

Add keys according to
[Flutter docs](https://docs.flutter.dev/deployment/android) and set the path in
`key.properties` to `/keystore/upload-keystore.jks` (this is where the
to-be-mounted volume points to; would recommend to keep the original path as a
comment for reference).

Execute the `build_android.sh` script:
`bash build_helpers/build_android.sh <path-to-keystore> <path-to-repository>`.
