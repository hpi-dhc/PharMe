import 'package:flutter/material.dart';

import '../theme.dart';

class Heading extends StatelessWidget {
  const Heading(
    this.text, {
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: PharMeTheme.textTheme.titleMedium);
  }
}
