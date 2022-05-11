# Code Style

All rules fall through to the [Effective Dart](https://dart.dev/guides/language/effective-dart)
guidelines.

## 1. All comments, identifiers, issues, etc. should be written in English

## 2. Limit code to contain 80 characters per line

Exceptions:

- documentation code
- hard-coded URLs (e.g., in comments)
- TODO comments should stay on a single line, so that tools can read & report
  the full message

## 3. Single- vs. Multi-line function calls

Put calls in a single line if they fit:

```dart
return Container(color: Colors.pink, child: myChild);
```

Wrap arguments with trailing comma if they exceed the char limit of 80 per line:

```dart
return Container(
  color: context.theme.primaryColor,
  padding: EdgeInsets.symmetric(horizontal: 16),
  child: myChild,
);
```

## 4. Always prefer relative to absolute imports

E.g. `import '../common/module.dart'` instead of `import '/common/module.dart'`

## 5. Use private functions/classes if they are only used locally

In Flutter, you make symbols private by prefixing them with an underscore (e.g. `_DatePickerState`).

## 6. Grouping and ordering concepts within a file

- Group concepts by their functionality vs. e.g. their return type
- Order these groups of concepts within a file by their relevance

  - E.g. Put helper methods beneath the methods they help

    Why? The name of helper methods should convey their function so you don't
    need to view their contents to get an initial understanding of the class.

```dart
import ...

int main() {
  helper1();
  helper2();
}

// Group 1
int helper1() { return helper11().toInt(); }

String helper11() { return '11'; }

// Group 2
int helper2() { return helper21().toInt(); }

String helper21() { return '21'; }
```

## 7. Base sizes, font sizes etc. on multiples of 4, preferably 8

E.g. 1, 2, 4, 8, (12), 16, (20), 24, 32, ...

## 8. Mark constructors as `const` where possible

## 9. Prefer using named arguments for functions with multiple arguments

## 10. Anonymous functions

- Use a tear-off (`names.forEach(print)` instead of
  `names.forEach((name) => print(name))`) when possible.
- Otherwise, use the arrow notation (`() => ...`) when possible.
- Use an explicit body (`() {...}`) if

  - there is more than one statement
  - the only statement contains an inner anonymous function
    (`() { transformStuff(() => ...); }`)
  - no part of the only statement fits in the same line and needs to be wrapped
    at the start

    ```dart
    int foo(Bar b) {
      return reeeaaallyLongFunctionNameThatGetsWrappedToNextLine(b).toInt()
    }
    ```

## 11. Prefer using extension methods to extend native/library concepts

```dart
extension FancyNum on num {
  num plus(num other) => this + other;
  num times(num other) => this * other;
}
```

`1.plus(2)` would return `3` now.

## 12. Prefer `await`/`async` to `myFuture.then((value) => ...)`

## 13. Prefer using the spread operator for combining lists

```dart
var a = [0,1,2,3,4];

var b = [6,7,8,9];

var c = [...a,5,...b];
```

## 14. Do not hard-code strings that will be displayed to the user

- Localize all strings used in the UI!
- Exception: When the UI needs a (flexible) array of strings or a map of strings,
  implementing this with localization is complex. Still, outsource these strings
  into a separate file. (e.g. FAQ: Array of question-answer pairs)

  Why?

  - Any string in the code can now be identified as a string that the code actually
    processes (e.g. HiveBox names, lookupkeys), so when you see one you can be sure
    it has nothing to do with UI.
  - With localization already set up, the app can easily be extended to support
    other languages.
  - Strings that repeat throughout the app (e.g. Unknown error) should come from
    a single source of truth.
