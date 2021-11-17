import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class MedicationDetailsPage extends StatelessWidget {
  const MedicationDetailsPage({@pathParam required this.id}) : super();

  final String id;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('It works. ID is $id'),
    );
  }
}
