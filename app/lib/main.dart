import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'common/module.dart';
import 'profile/models/hive/alleles.dart';
import 'profile/models/hive/diplotype.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AllelesAdapter());
  Hive.registerAdapter(DiplotypeAdapter());
  await Hive.openBox<Alleles>('userData');
  await Hive.openBox('preferences');
  await dotenv.load(fileName: '.env');
  runApp(FrasecysApp());
}
