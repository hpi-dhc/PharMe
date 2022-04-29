import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../common/constants.dart';
import '../../../common/module.dart';
import '../../../common/theme.dart';
import '../../models/medication.dart';
import 'cubit.dart';

final _panelController = PanelController();

class MedicationsOverviewPage extends HookWidget {
  const MedicationsOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final foundMedications = useState<List<Medication>>([]);
    Timer? searchTimeout;
    const duration = Duration(milliseconds: 200);

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
              SlidingUpPanel(
                color: Colors.transparent,
                controller: _panelController,
                maxHeight: 1000,
                panelBuilder: (scrollController) {
                  return RoundedCard(
                    // ignore: unnecessary_lambdas
                    onTap: () => _panelController.open(),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: CupertinoSearchTextField(
                                    controller: searchController,
                                    onTap: _panelController.open,
                                    onChanged: (value) async {
                                      if (value == '') return;

                                      if (searchTimeout != null) {
                                        searchTimeout!.cancel();
                                      }
                                      searchTimeout = Timer(
                                        duration,
                                        () async {
                                          final requestUri =
                                              annotationServerUrl.replace(
                                            path: 'api/v1/medications',
                                            queryParameters: {'search': value},
                                          );
                                          context
                                              .read<MedicationsOverviewCubit>()
                                              .setState(
                                                MedicationsOverviewState
                                                    .loading(),
                                              );
                                          final response =
                                              await http.get(requestUri);

                                          if (response.statusCode != 200) {
                                            context
                                                .read<
                                                    MedicationsOverviewCubit>()
                                                .setState(
                                                  MedicationsOverviewState
                                                      .error(),
                                                );
                                            return;
                                          }
                                          foundMedications.value =
                                              medicationsFromHTTPResponse(
                                                  response);
                                          context
                                              .read<MedicationsOverviewCubit>()
                                              .setState(
                                                MedicationsOverviewState.loaded(
                                                  foundMedications.value,
                                                ),
                                              );
                                        },
                                      );
                                    },
                                  ),
                                );
                              }
                              return state.when(
                                initial: Container.new,
                                error: () => Text('smth went wrong'),
                                loaded: (medications) => Column(
                                  children: [
                                    for (final e in medications) ...[
                                      MedicationCard(
                                        onTap: () => print('test'),
                                        medicationName: e.name,
                                        medicationDescription: e.indication,
                                      ),
                                      SizedBox(height: 8),
                                    ]
                                  ],
                                ),
                                loading: () =>
                                    Center(child: CircularProgressIndicator()),
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
        },
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  MedicationCard(
      {this.padding = const EdgeInsets.all(16),
      this.isSafe = true,
      required this.onTap,
      required this.medicationName,
      required this.medicationDescription});

  final EdgeInsets padding;
  final VoidCallback onTap;
  final String medicationName;
  final String medicationDescription;
  final bool isSafe;

  final borderRadius = BorderRadius.all(Radius.circular(15));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // TODO(somebody): find nice colors
          color: isSafe ? Color(0xFFAFE1AF) : Color(0xFFF5B9B4),
          border: Border.all(width: 0.5, color: Colors.black.withOpacity(0.2)),
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(medicationName, style: PharmeTheme.textTheme.titleLarge),
              SizedBox(height: 6),
              Text(
                medicationDescription,
                style: PharmeTheme.textTheme.subtitle2,
              )
            ],
          ),
        ),
      ),
    );
  }
}
