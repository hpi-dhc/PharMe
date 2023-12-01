import 'package:flutter_list_view/flutter_list_view.dart';

import '../module.dart';

Widget scrollList(List<Widget> body, {bool keepPosition = false}) {
  String getItemKey(Widget widget) => widget.key.toString();
  if (body.map(getItemKey).toSet().length != body.length) {
    throw Exception('Items passed to scrollList need unique keys');
  }
  return Expanded(
    child: Scrollbar(
      thumbVisibility: true,
      thickness: PharMeTheme.smallSpace / 2,
      child: Padding(
        padding: EdgeInsets.only(right: PharMeTheme.smallSpace * 1.5),
        child: FlutterListView(
          delegate: FlutterListViewDelegate(
              (context, index) => body[index],
              childCount: body.length,
              onItemKey: (index) => getItemKey(body[index]),
              keepPosition: keepPosition,
              // keepPositionOffset: 80,
              // firstItemAlign: FirstItemAlign.end
          )
        )
      )
    ),
  );
}