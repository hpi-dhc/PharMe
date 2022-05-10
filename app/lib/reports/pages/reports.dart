import '../../common/models/medication.dart';
import '../../common/module.dart';
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
    // TODO(kolioOtSofia): filter relevant guidelines and remove medications with ok warning levels only #270
    return Flexible(
      child: ListView.separated(
          itemBuilder: (context, index) {
            final el = medications[index];
            return ReportCard(
              warningLevel:
                  _convertToWarningLevel(el.guidelines[0].warningLevel),
              onTap: () {},
              medicationName: el.name,
              medicationDescription: el.description,
            );
          },
          separatorBuilder: (_, __) => SizedBox(height: 8),
          itemCount: medications.length),
    );
  }

  WarningLevel _convertToWarningLevel(String? str) {
    switch (str) {
      case 'danger':
        return WarningLevel.danger;
      case 'warning':
        return WarningLevel.warning;
      case 'ok':
        return WarningLevel.ok;
      default:
        throw Exception('Warning level not supperted');
    }
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
