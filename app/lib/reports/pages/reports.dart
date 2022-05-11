import '../../common/models/guideline.dart';
import '../../common/models/medication.dart';
import '../../common/module.dart';
import '../../common/utilities/medication_utils.dart';
import '../../medications/pages/overview/page.dart';
import 'cubit.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportsCubit(),
      child: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          return RoundedCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Column(children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: PharmeTheme.secondaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(children: [
                      Text(
                        context.l10n.reports_page_disclaimer_title,
                        style: PharmeTheme.textTheme.headline6!
                            .copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              context.l10n.reports_page_disclaimer_text,
                              style: PharmeTheme.textTheme.bodyMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                          SvgPicture.asset('assets/images/reports_icon.svg')
                        ],
                      )
                    ]),
                  ),
                ),
                state.when(
                  initial: Container.new,
                  error: () => Text(context.l10n.err_generic),
                  loading: () => Center(child: CircularProgressIndicator()),
                  loaded: _buildMedicationsList,
                )
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationsList(List<MedicationWithGuidelines> medications) {
    var filteredMedications =
        medications.map(extractRelevantGuidelineFromMedication).toList();
    filteredMedications = filteredMedications
        .where((element) =>
            element.guidelines.isNotEmpty &&
            !_containsOnlyOkGuidelines(element.guidelines))
        .toList();

    return Flexible(
      child: ListView.separated(
          itemBuilder: (context, index) {
            final el = filteredMedications[index];
            return ReportCard(
              warningLevel: _extractWarningLevelFromGuidelines(el.guidelines),
              onTap: () {},
              medicationName: el.name,
              medicationDescription: el.description,
            );
          },
          separatorBuilder: (_, __) => SizedBox(height: 8),
          itemCount: filteredMedications.length),
    );
  }

  WarningLevel _extractWarningLevelFromGuidelines(List<Guideline> guidelines) {
    for (final guideline in guidelines) {
      if (guideline.warningLevel == WarningLevel.danger.name) {
        return WarningLevel.danger;
      }
    }
    return WarningLevel.warning;
  }

  bool _containsOnlyOkGuidelines(List<Guideline> guidelines) {
    final warningLevels = guidelines.map((e) => e.warningLevel);
    return warningLevels
        .every((warningLevel) => warningLevel == WarningLevel.ok.name);
  }
}

class ReportCard extends MedicationCard {
  const ReportCard({
    required this.warningLevel,
    required VoidCallback onTap,
    required String medicationName,
    String? medicationDescription,
  }) : super(
          onTap: onTap,
          medicationName: medicationName,
          medicationDescription: medicationDescription,
        );

  final WarningLevel warningLevel;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      color: warningLevel == WarningLevel.danger
          ? Color(0xFFFFAFAF)
          : Color(0xFFFFEBCC),
      child: GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(children: [
                  Row(children: [
                    Icon(
                      warningLevel == WarningLevel.danger
                          ? Icons.block_flipped
                          : Icons.warning_amber,
                    ),
                    SizedBox(width: 10),
                    Text(
                      medicationName,
                      style: PharmeTheme.textTheme.titleMedium,
                    ),
                  ]),
                  SizedBox(height: 10),
                  if (medicationDescription != null)
                    Text(
                      medicationDescription!,
                      style: PharmeTheme.textTheme.subtitle2,
                    )
                ]),
              ),
              Icon(Icons.arrow_forward_ios)
            ],
          ),
        ),
      ),
    );
  }
}

enum WarningLevel {
  danger,
  warning,
  ok,
}
