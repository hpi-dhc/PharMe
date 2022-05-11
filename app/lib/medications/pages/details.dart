import '../../common/module.dart';

class MedicationDetailsPage extends StatelessWidget {
  const MedicationDetailsPage({@pathParam required this.id}) : super();

  final String id;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(context.l10n.medications_details_page_working(id)),
    );
  }
}
