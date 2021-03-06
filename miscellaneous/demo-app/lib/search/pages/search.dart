import 'package:flutter/cupertino.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';

import '../../../common/module.dart';
import 'cubit.dart';

final _panelController = SlidingUpPanelController();

class SearchPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();

    return BlocProvider(
      create: (context) => SearchCubit(),
      child: BlocBuilder<SearchCubit, SearchState>(
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
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 200),
                    child: Image.asset(
                      'assets/images/logo-vertical.png',
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                child: SizedBox.expand(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        context.l10n.search_page_typeInMedication,
                        style: PharmeTheme.textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.arrow_downward,
                        size: 30,
                        color: Colors.white,
                      ),
                      SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
              SlidingUpPanelWidget(
                onTap: _panelController.expand,
                controlHeight: 150,
                panelController: _panelController,
                child: RoundedCard(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: CupertinoSearchTextField(
                          onTap: _panelController.expand,
                          controller: searchController,
                          onChanged: (value) {
                            context.read<SearchCubit>().loadMedications(value);
                          },
                        ),
                      ),
                      state.when(
                        initial: Container.new,
                        error: () => Text(context.l10n.err_generic),
                        loaded: _buildMedicationsList,
                        loading: Container.new,
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

  Flexible _buildMedicationsList(List<Medication> medications) {
    return Flexible(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 14),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final med = medications[index];
          return MedicationCard(
            onTap: () => context.router.push(MedicationRoute(id: med.id)),
            medicationName: med.name,
          );
        },
        separatorBuilder: (_, __) => SizedBox(height: 8),
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  const MedicationCard({
    required this.onTap,
    required this.medicationName,
    this.medicationDescription,
  });

  final VoidCallback onTap;
  final String medicationName;
  final String? medicationDescription;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      medicationName,
                      style: PharmeTheme.textTheme.titleMedium,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios),
                ],
              ),
              SizedBox(height: 6),
              if (medicationDescription.isNotNullOrBlank)
                Text(
                  medicationDescription!,
                  style: PharmeTheme.textTheme.titleSmall,
                )
            ],
          ),
        ),
      ),
    );
  }
}
