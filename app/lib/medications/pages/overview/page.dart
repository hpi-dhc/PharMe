import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../common/module.dart';
import '../../models/medication.dart';
import 'cubit.dart';

class MedicationsOverviewPage extends HookWidget {
  const MedicationsOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();

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
              _matchingMedicationsTiles(medications, searchController.text),
              searchController,
            ),
          );
        },
      ),
    );
  }

  bool _matches(String test, String query) {
    return test.toLowerCase().contains(query.toLowerCase().trim());
  }

  List<MedicationTile> _matchingMedicationsTiles(
    List<Medication> medications,
    String searchText,
  ) {
    final medicationTiles = medications
        .map((medication) {
          final synonymMatch = medication.synonyms
              .any((synonym) => _matches(synonym, searchText));

          int priority;

          if (_matches(medication.name, searchText)) {
            priority = 2;
          } else if (synonymMatch) {
            priority = 1;
          } else if (_matches(medication.description, searchText)) {
            priority = 0;
          } else {
            return null;
          }

          return MedicationTile(medication: medication, priority: priority);
        })
        .whereType<MedicationTile>()
        .toList();

    medicationTiles.sort((medication1, medication2) =>
        medication2.priority.compareTo(medication1.priority));

    return medicationTiles;
  }

  Column _buildMedicationsList(
    BuildContext context,
    List<MedicationTile> medicationsTiles,
    TextEditingController searchController,
  ) {
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
            itemCount: medicationsTiles.length,
            itemBuilder: (context, index) {
              final medicationsTile = medicationsTiles[index];
              return Card(
                child: medicationsTile,
              );
            },
          ),
        ),
      ],
    );
  }
}

class MedicationTile extends StatelessWidget {
  const MedicationTile({
    Key? key,
    required this.medication,
    required this.priority,
  }) : super(key: key);

  final Medication medication;
  final int priority;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(medication.name),
      subtitle: Text(medication.description,
          maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: () =>
          context.router.pushNamed('main/medications/${medication.id}'),
    );
  }
}
