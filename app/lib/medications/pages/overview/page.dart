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
                    _matchingMedicationsTiles(
                        medications, searchController.text),
                    searchController.text,
                  ));
        },
      ),
    );
  }

  bool _matches(String test, String query) {
    return test.toLowerCase().contains(query.toLowerCase().trim());
  }

  List<ListTile> _matchingMedicationsTiles(
      List<Medication> medications, String searchText) {
    return medications
        .map((medication) {
          final synonymMatch = medication.synonyms
              .any((synonym) => _matches(synonym, searchText));

          if (!_matches(medication.name, searchText) &&
              !synonymMatch &&
              !_matches(medication.description, searchText)) {
            return null;
          }

          return ListTile(
            title: Text(medication.name),
            subtitle: Text(medication.description,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () =>
                context.router.pushNamed('main/medications/${medication.id}'),
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
