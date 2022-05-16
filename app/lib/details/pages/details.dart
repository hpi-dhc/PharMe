import '../../common/module.dart';

class MedicationDetailsPage extends StatelessWidget {
  const MedicationDetailsPage({required this.medication}) : super();

  final MedicationWithGuidelines medication;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text(medication.name),),
    );
  }
}
