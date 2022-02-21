import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/module.dart';
import '../../models/medication.dart';
import 'cubit.dart';

class MedicationsOverviewPage extends StatefulWidget {
  const MedicationsOverviewPage({Key? key}) : super(key: key);

  @override
  State<MedicationsOverviewPage> createState() =>
      _MedicationsOverviewPageState();
}

class _MedicationsOverviewPageState extends State<MedicationsOverviewPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {});
    });
  }

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
            loaded: (medications) => _buildMedicationsList(
                context,
                medications
                    .where((medication) => medication.rxstring
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()))
                    .toList()),
          );
        },
      ),
    );
  }

  Column _buildMedicationsList(
      BuildContext context, List<Medication> medications) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: context.l10n.overview_search_bar_search,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return Card(
                child: ListTile(
                  title: Text(medication.rxstring),
                  onTap: () => context.router
                      .pushNamed('main/medications/${medication.setid}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
