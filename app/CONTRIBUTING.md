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

## Updating Flutter and Android

... can be super painful, because Java, Gradle, and Kotlin versions may be
wrong.

Often problems in packages arise that rely on older Gradle versions.

The places to check are:

- Your Flutter version
- Your `JAVA_HOME` version
- The Gradle version in `gradle-wrapper.properties`; the recommended versions
  are "between 7.3 and 7.6.1." (see
  [Android Java Gradle migration guide](https://docs.flutter.dev/release/breaking-changes/android-java-gradle-migration-guide))
- The Java version in `android/app/build/gradle`
- The Java version used for Gradle (check in Android Studio)
- The Kotlin version in `settings.gradle`

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
    - declares all routes as functions returning `AutoRoute`
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
    ...children, // includes myChildRoute()
  ],
);
```

## Making app icons

Add the icon as `assets/icon/icon.png` (configured in `pubspec.yaml`) and run

```shell
flutter pub run flutter_launcher_icons:main
```

This will generate icons for both iOS as well as Android.

Another option is to use, e.g., <https://easyappicon.com/>.

## Updating screencast and screenshots

🙅 _Not working yet due to login redirect, but keeping script for Sinai_
_version (login without redirect) – can adopt once different login types are_
_supported._

_Check `e60efb4f2fc3ba2efa7735ffb06ec5fdb64d7af6` for a rudimentary script_
_version, removed afterwards due to too many merge conflicts._

## User Instructions

Currently, the user instructions are a static HTML file that need to be updated
manually if changes in the app content occur (at least the screenshots are
linked and do not need to be updated after re-generation).

We decided to host a PDF of the user instructions (for the study). To create
this PDF, follow these steps:

1. Open the HTML file in Chrome
2. Print with "Save to PDF" using default settings, format US Letter
3. Add page numbers [online](https://www.ilovepdf.com/add_pdf_page_number)
   - Position: bottom center
   - Text: `{n} of {p}`
   - Font size: 10

## Adapting test data

If you would like to test with specific test data but you don't have a user with
suitable data available, adapt the code that gets the lab results as shown below.

```dart
// TODO(after-testing): remove test data adaption
var labResults = json.map<LabResult>(LabResult.fromJson).toList();
final cyp2c19Result = labResults.firstWhere((labResult) => labResult.gene == "CYP2C19");
labResults = labResults.filter((labResult) => labResult.gene != "CYP2C19").toList();
labResults = [...labResults, LabResult(gene: "CYP2C19", variant: "*2/*2", phenotype: "Poor Metabolizer", allelesTested: cyp2c19Result.allelesTested)];
return labResults;
```

You can use the CPIC API to get reasonable genotype-phenotype pairings, e.g.,
with
`https://api.cpicpgx.org/v1/diplotype?genesymbol=eq.CYP2C9&select=genesymbol,diplotype,generesult`.

Some more examples are collected below (this is for testing what is shown for
Warfarin):

```dart
  UserData.instance.diplotypes!['CYP2C9'] = Diplotype(
    gene: 'CYP2C9',
    resultType: 'Diplotype',
    genotype: '*11/*13',
    phenotype: 'Poor Metabolizer',
    allelesTested: '',
  );
  UserData.instance.diplotypes!['VKORC1'] = Diplotype(
    gene: 'VKORC1',
    resultType: 'Diplotype',
    genotype: '-1639G>A variant carriers',
    phenotype: '-1639G>A variant carriers',
    allelesTested: '',
  );
  UserData.instance.diplotypes!['CYP4F2'] = Diplotype(
    gene: 'CYP4F2',
    resultType: 'Diplotype',
    genotype: 'rs2108622 T carriers',
    phenotype: 'rs2108622 T carriers',
    allelesTested: '',
  );
  UserData.instance.diplotypes!['CYP2C'] = Diplotype(
    gene: 'CYP2C',
    resultType: 'Diplotype',
    genotype: 'rs12777823 A carriers',
    phenotype: 'rs12777823 A carriers',
    allelesTested: '',
  );
```

## Building with Docker

You cannot update your Dart or Flutter versions locally?
Use Docker to build for Android:

```bash
# DO: adapt key names to your local setup
docker build -t flutter-dev -f Dockerfile.dev \
--secret id=github_private_key,src=$HOME/.ssh/github \
--secret id=github_public_key,src=$HOME/.ssh/github.pub .

docker run -it --rm -v ./:/app -w /app flutter-dev

# DO: In container, run commands as described above in local setup

# Accept Android licenses:
flutter doctor --android-licenses

# Run build commands, e.g.:
flutter build apk
```

**TODO: Test** Build the app or expose a port to run as web app.
