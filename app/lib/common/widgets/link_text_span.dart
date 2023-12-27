import 'package:flutter/gestures.dart';

import '../module.dart';

TextSpan linkTextSpan({required String text, required void Function() onTap}) =>
  TextSpan(
    text: text,
    style: TextStyle(
      color: PharMeTheme.secondaryColor,
      decoration: TextDecoration.underline,
    ),
    recognizer: TapGestureRecognizer()..onTap = onTap,
  );