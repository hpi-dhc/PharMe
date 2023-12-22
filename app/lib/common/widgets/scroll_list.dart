import 'package:flutter_list_view/flutter_list_view.dart';

import '../module.dart';

Widget scrollList(List<Widget> body, {
  bool keepPosition = false,
  double? verticalPadding,
}) {
  String getItemKey(Widget widget) => widget.key.toString();
  if (body.map(getItemKey).toSet().length != body.length) {
    throw Exception('Items passed to scrollList need unique keys');
  }
  return Expanded(
    child: Scrollbar(
      thumbVisibility: true,
      thickness: PharMeTheme.smallSpace / 2,
      child: Padding(
        padding: EdgeInsets.only(right: PharMeTheme.mediumSpace),
        child: FlutterListView(
          delegate: FlutterListViewDelegate(
              (context, index) => (index == 0)
                ? Padding(
                    padding: EdgeInsets.only(
                      top: verticalPadding ?? PharMeTheme.smallSpace,
                    ),
                    child: body[index]
                  )
                : (index == body.length - 1)
                  ? Padding(
                      padding: EdgeInsets.only(
                        bottom: verticalPadding ?? PharMeTheme.smallSpace,
                      ),
                      child: body[index]
                    )
                  : body[index],
              childCount: body.length,
              onItemKey: (index) => getItemKey(body[index]),
              keepPosition: keepPosition,
          )
        )
      )
    ),
  );
}