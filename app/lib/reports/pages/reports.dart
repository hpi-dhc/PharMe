import '../../common/models/guideline.dart';
import '../../common/models/medication.dart';
import '../../common/module.dart';
import '../../common/utilities/medication_utils.dart';
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
    return CustomScrollView(slivers: [
      SliverPersistentHeader(
        delegate: SliverReportsHeaderDelegate(50, 100, 150),
        floating: true,
      ),
      _buildMedicationsList(medications),
    ]);
  }

  Widget _buildMedicationsList(List<MedicationWithGuidelines> medications) {
    var filteredMedications =
        medications.map(extractRelevantGuidelineFromMedication).toList();
    filteredMedications = filteredMedications
        .where((element) =>
            element.guidelines.isNotEmpty &&
            !_containsOnlyOkGuidelines(element.guidelines))
        .toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final med = filteredMedications[index];
        return ReportCard(
          warningLevel: _extractWarningLevelFromGuidelines(med.guidelines),
          onTap: () {},
          medicationName: med.name,
          medicationDescription: med.description,
        );
      }, childCount: filteredMedications.length),
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

class SliverReportsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SliverReportsHeaderDelegate(
      this.toolBarHeight, this.closedHeight, this.openHeight)
      : super();

  final double toolBarHeight;
  final double closedHeight;
  final double openHeight;

  @override
  double get maxExtent => toolBarHeight + openHeight;

  @override
  double get minExtent => toolBarHeight + closedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: PharmeTheme.secondaryColor,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          Text(
            context.l10n.reports_page_disclaimer_title,
            style:
                PharmeTheme.textTheme.headline6!.copyWith(color: Colors.white),
          ),
          SizedBox(height: 6),
          Expanded(
            child: Row(
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
            ),
          )
        ]),
      ),
    );
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
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        color: warningLevel == WarningLevel.danger
            ? Color(0xFFFFAFAF)
            : Color(0xFFFFEBCC),
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
