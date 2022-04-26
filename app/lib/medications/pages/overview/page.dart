import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../common/module.dart';
import '../../../common/theme.dart';
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

  Widget _buildMedicationsList(
    BuildContext context,
    List<MedicationTile> medicationsTiles,
    TextEditingController searchController,
  ) {
    final panelController = PanelController();

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PharmeTheme.primaryColor,
                PharmeTheme.secondaryColor,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/logo.svg'),
              Text(
                'Type in a medication',
                style: PharmeTheme.textTheme.bodyLarge!
                    .copyWith(color: Colors.white),
              ),
              Icon(
                Icons.arrow_downward,
                size: 30,
                color: Colors.white,
              ),
              SizedBox(height: 120),
            ],
          ),
        ),
        SlidingUpPanel(
          color: Colors.transparent,
          controller: panelController,
          maxHeight: 1000,
          panelBuilder: (scrollController) {
            return RoundedCard(
              onTap: () => panelController.open(),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: medicationsTiles.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: CupertinoSearchTextField(
                              controller: searchController,
                              // TODO(somebody): send requests
                              onTap: () {
                                print('test');
                              },
                              onChanged: (value) => {},
                            ),
                          );
                        }

                        final medicationsTile = medicationsTiles[index];
                        return Card(
                          child: medicationsTile,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
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
