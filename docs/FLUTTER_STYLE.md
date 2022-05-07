# Code Style

All rules fall through to the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines.

### 1. All comments, identifiers, issues, etc. should be written in English.

### 2. Limit code to contain 80 characters per line.

Exceptions:

- documentation code
- hard-coded URLs (e.g., in comments)
- TODO comments should stay on a single line, so that tools can read & report the full message

### 3. Single- vs. Multi-line function calls

Put calls in a single line if they fit:

```dart
return Container(color: Colors.pink, child: myChild);
```

Wrap if there are more than two named parameters, they get longer:

```dart
return Container(
  color: context.theme.primaryColor,
  padding: EdgeInsets.symmetric(horizontal: 16),
  child: myChild,
);
```

### 4. Always prefer relative to absolute imports.

E.g. `import '../common/module.dart'` instead of `import '/common/module.dart'`

### 5. Use private functions/classes if they are only used locally

In Flutter, you make symbols private by prefixing them with an underscore (e.g. `_DatePickerState`).

### 6. Group concepts within a file by their functionality

### 7. Order these groups of concepts within a file by their relevance

E.g. Put helper methods beneath the methods they help

Why? The name of helper methods should convey their function so you don't need to view their contents to get an initial understanding of the class.

### 8. Mark constructors as `const` where possible.

### 9. Prefer using named arguments for functions with multiple arguments.

### 10. Anonymous functions

Use a tear-off (`names.forEach(print)` instead of `names.forEach((name) => print(name))`) when possible. Otherwise, use the arrow notation (`() => ...`) when possible. Use an explicit body (`() {...}`) if that statement contains an inner anonymous function (`() { transformStuff(() => ...); }`).

### 11. Prefer using extension methods to extend native/library concepts

```dart
extension FancyNum on num {
  num plus(num other) => this + other;
  num times(num other) => this * other;
}
```

`1.plus(2)` would return `3` now.

### 12. Prefer `await`/`async` to `myFuture.then((value) => ...)`

### 13. Prefer using the spread operator for combining lists

```dart
var a = [0,1,2,3,4];

var b = [6,7,8,9];

var c = [...a,5,...b];
```
