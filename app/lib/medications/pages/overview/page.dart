import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/module.dart';
import '../../../common/theme.dart';
import 'cubit.dart';

final panelController = SlidingUpPanelController();

class MedicationsOverviewPage extends StatelessWidget {
  const MedicationsOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();

    return BlocProvider(
      create: (context) => MedicationsOverviewCubit(),
      child: BlocBuilder<MedicationsOverviewCubit, MedicationsOverviewState>(
        builder: (context, state) {
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
              SlidingUpPanelWidget(
                controlHeight: 150,
                panelController: panelController,
                child: RoundedCard(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: CupertinoSearchTextField(
                          controller: searchController,
                          onChanged: (value) {
                            context
                                .read<MedicationsOverviewCubit>()
                                .loadMedications(value);
                          },
                        ),
                      ),
                      state.when(
                        initial: Container.new,
                        error: () => Text('smth went wrong'),
                        loaded: (medications) => Flexible(
                          child: ListView.builder(
                            itemCount: medications.length,
                            itemBuilder: (context, index) {
                              final el = medications[index];
                              return MedicationCard(
                                onTap: () {},
                                medicationName: el.name,
                              );
                            },
                          ),
                        ),
                        loading: () =>
                            Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  const MedicationCard({
    this.isSafe = true,
    required this.onTap,
    required this.medicationName,
    this.medicationDescription,
  });

  final VoidCallback onTap;
  final String medicationName;
  final String? medicationDescription;
  final bool isSafe;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 20,
      color: isSafe ? Color(0xFFAFE1AF) : Color(0xFFF5B9B4),
      child: GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(medicationName, style: PharmeTheme.textTheme.titleLarge),
              SizedBox(height: 6),
              if (medicationDescription != null)
                Text(
                  medicationDescription!,
                  style: PharmeTheme.textTheme.subtitle2,
                )
            ],
          ),
        ),
      ),
    );
  }
}
