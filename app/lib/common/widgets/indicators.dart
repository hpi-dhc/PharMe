import '../module.dart';

Widget loadingIndicator() =>
    genericIndicator(child: CircularProgressIndicator());
Widget errorIndicator(String description) =>
    genericIndicator(child: Text(description, textAlign: TextAlign.center));

Widget genericIndicator({required Widget child}) => Center(
    child: Padding(
        padding: EdgeInsets.symmetric(vertical: 100, horizontal: 20),
        child: child));
