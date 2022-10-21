import '../module.dart';

Widget loadingIndicator() => _indicator(child: CircularProgressIndicator());
Widget errorIndicator(String description) =>
    _indicator(child: Text(description));

Widget _indicator({required Widget child}) => Center(
    child: Padding(padding: EdgeInsets.symmetric(vertical: 100), child: child));
