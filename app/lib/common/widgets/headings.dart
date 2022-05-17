import 'package:black_hole_flutter/black_hole_flutter.dart';
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
    return Text(text, style: PharmeTheme.textTheme.titleMedium);
  }
}
