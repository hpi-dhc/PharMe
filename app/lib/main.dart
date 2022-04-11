import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'common/module.dart';
import 'common/services.dart';

Future<void> main() async {
  await dotenv.load(mergeWith: Platform.environment);
  await initServices();
  runApp(PharmeApp());
}
