import '../../common/module.dart';
import '../models/warning_level.dart';
import 'cubit.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportsCubit(),
      child: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          return RoundedCard(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: state.when(
              initial: Container.new,
              error: () => Text(context.l10n.err_generic),
              loading: () => Center(child: CircularProgressIndicator()),
              loaded: (medications) => _buildReportsPage(medications, context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportsPage(
    List<MedicationWithGuidelines> medications,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _buildHeaderCard(context),
            SizedBox(height: 8),
            _buildMedicationsList(context, medications)
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PharmeTheme.primaryColor.shade500,
            PharmeTheme.primaryColor.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: SvgPicture.asset(
              'assets/images/reports_icon.svg',
              width: 70,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.reports_page_disclaimer_title,
                  style: PharmeTheme.textTheme.titleMedium!
                      .copyWith(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  context.l10n.reports_page_disclaimer_text,
                  style: PharmeTheme.textTheme.bodyMedium!
                      .copyWith(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMedicationsList(
    BuildContext context,
    List<MedicationWithGuidelines> medications,
  ) {
    return Column(
      children: [
        ...medications.map(
          (medication) => ReportCard(
            warningLevel: _getWarningLevel(medication.guidelines),
            medicationName: medication.name,
            medicationDescription: medication.indication,
            onTap: () =>
                context.router.push(MedicationRoute(id: medication.id)),
          ),
        ),
      ],
    );
  }

  WarningLevel _getWarningLevel(List<Guideline> guidelines) {
    for (final guideline in guidelines) {
      if (guideline.warningLevel == WarningLevel.danger.name) {
        return WarningLevel.danger;
      }
    }
    return WarningLevel.warning;
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard({
    required this.warningLevel,
    required this.onTap,
    required this.medicationName,
    this.medicationDescription,
  }) : super();

  final WarningLevel warningLevel;
  final VoidCallback onTap;
  final String medicationName;
  final String? medicationDescription;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        color: warningLevel == WarningLevel.danger
            ? Color(0xFFFFAFAF)
            : Color(0xFFFFEBCC),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(
                        warningLevel == WarningLevel.danger
                            ? Icons.block_flipped
                            : Icons.warning_amber,
                      ),
                      SizedBox(width: 12),
                      Text(
                        medicationName,
                        style: PharmeTheme.textTheme.titleMedium,
                      ),
                    ]),
                    SizedBox(height: 12),
                    if (medicationDescription.isNotNullOrBlank)
                      Text(
                        medicationDescription!,
                        style: PharmeTheme.textTheme.titleSmall,
                      ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
