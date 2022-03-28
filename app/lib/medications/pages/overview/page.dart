import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/module.dart';
import '../../models/medications_group.dart';
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
            loaded: (medicationsGroups) => _buildMedicationsList(
              context,
              _matchingMedicationsTiles(
                  medicationsGroups, searchController.text),
              searchController.text,
            ),
          );
        },
      ),
    );
  }

  bool _matches(String test, String query) {
    return test.toLowerCase().contains(query.toLowerCase().trim());
  }

  List<ListTile> _matchingMedicationsTiles(
      List<MedicationsGroup> medicationsGroups, String searchText) {
    return medicationsGroups
        .map((group) {
          final matchingMedications = group.medications
              .where((medication) =>
                  _matches(medication.name, searchText) ||
                  _matches(medication.manufacturer, searchText))
              .toList();

          if (matchingMedications.isEmpty &&
              !_matches(group.name, searchText)) {
            return null;
          }

          final title = matchingMedications.isEmpty
              ? group.name
              : matchingMedications
                  .map((medication) => medication.name)
                  .toSet()
                  .join(', ');
          final subtitle = matchingMedications.isEmpty ? null : group.name;
          return ListTile(
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: subtitle == null ? null : Text(subtitle),
            onTap: () =>
                context.router.pushNamed('main/medications/${group.id}'),
          );
        })
        .whereType<ListTile>()
        .toList();
  }

  Column _buildMedicationsList(BuildContext context,
      List<ListTile> medicationsTiles, String searchText) {
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
