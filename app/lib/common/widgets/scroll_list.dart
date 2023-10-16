import '../module.dart';

Widget scrollList(List<Widget> body) {
  return Expanded(
            child: Scrollbar(
                    thumbVisibility: true,
                    thickness: PharMeTheme.smallSpace / 2,
                    child: ListView(
                      padding: EdgeInsets.only(
                      right: PharMeTheme.smallSpace * 1.5
                      // right: 0
                    ),
              children: [
                SizedBox(height: 8),
                ...body,
            ])
          ));
}