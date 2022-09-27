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

### `secrets.properties`

The CHDP libraries require a few secrets to build. In
[`android/secrets.properties`](android/secrets.properties) (gitignored) add the
following keys and appropriate values:

```properties
gpr.user=
gpr.token=

d4l.clientId=
d4l.clientSecret=
```

The first two are a Github username and Personal Access Token with the
`read:packages` scope. This is used by gradle to download the SDK from D4L's
private repositories.

The next two are secrets given by D4L.  Ask Thomas at Thomas.Harris (at) hpi.de
for them.

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
