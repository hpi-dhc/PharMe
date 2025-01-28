import '../module.dart';

Widget loadingIndicator() =>
    genericIndicator(child: CircularProgressIndicator(), verticalPadding: 100);
Widget errorIndicator(String description) =>
    genericIndicator(
      child: Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      verticalPadding: PharMeTheme.mediumToLargeSpace,
    );

Widget genericIndicator({required Widget child, required double verticalPadding}) => Center(
    child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: PharMeTheme.mediumToLargeSpace,
        ),
        child: child));
