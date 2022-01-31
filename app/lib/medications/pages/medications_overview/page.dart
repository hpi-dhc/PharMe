import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/medication.dart';
import 'cubit.dart';

class MedicationsOverviewPage extends StatefulWidget {
  const MedicationsOverviewPage({Key? key}) : super(key: key);

  @override
  State<MedicationsOverviewPage> createState() =>
      _MedicationsOverviewPageState();
}

class _MedicationsOverviewPageState extends State<MedicationsOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicationsOverviewCubit(),
      child: BlocBuilder<MedicationsOverviewCubit, MedicationsOverviewState>(
        builder: (context, state) {
          return state.when(
            initial: Container.new,
            loading: () => Center(child: CircularProgressIndicator()),
            error: () => Center(child: Text('Error!')),
            loaded: (medications) =>
                _buildMedicationsList(context, medications),
          );
        },
      ),
    );
  }

  ListView _buildMedicationsList(
      BuildContext context, List<Medication> medications) {
    return ListView.builder(
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final post = medications[index];
        return Card(
          child: ListTile(
            title: Text(post.rxstring),
            onTap: () =>
                context.router.pushNamed('main/medications/${post.setid}'),
          ),
        );
      },
    );
  }
}
