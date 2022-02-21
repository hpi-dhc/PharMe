import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('Reports Page'),
          MaterialButton(onPressed: () {
            // ignore: avoid_print
            print(Hive.box('preferences').get('isOnboardingCompleted'));
          })
        ],
      ),
    );
  }
}
