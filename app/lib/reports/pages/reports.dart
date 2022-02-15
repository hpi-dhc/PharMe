import 'package:app/profile/models/hive/alleles.dart';
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
            print(Hive.box('preferences').get('isOnboardingCompleted'));
          })
        ],
      ),
    );
  }
}
