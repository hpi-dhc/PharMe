import 'package:popover/popover.dart';

import '../module.dart';

class ContextMenu extends StatelessWidget {
  const ContextMenu({
    super.key,
    this.headerItem,
    required this.items,
    required this.child,
  });

  final Widget? headerItem;
  final List<ContextMenuCheckmark> items;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showPopover(
            context: context,
            bodyBuilder: (context) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: PharMeTheme.smallToMediumSpace
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: PharMeTheme.onSurfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildContent(context),
                  ),
                ),
              ),
            ),
            direction: PopoverDirection.bottom,
            arrowHeight: 0,
            arrowWidth: 0,
            transitionDuration: Duration(milliseconds: 100),
            barrierColor: Color.fromRGBO(0, 0, 0, 0.05),
            backgroundColor: Color.fromRGBO(1, 1, 1, 0),
            shadow: [],
          );
        },
        child: child);
  }

  Widget _itemContainer(
    Widget item,
    {
      bool showBorder = true,
      double padding = PharMeTheme.smallToMediumSpace,
    }
  ) {
    return Container(
      decoration: showBorder ? BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: PharMeTheme.borderColor
          ),
        ),
      ) : null,
      child: Padding(
          padding: EdgeInsets.all(padding),
          child: item,
      )
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    final body = items.mapIndexed(
      (index, item) => (index == items.count() - 1)
          ? _itemContainer(item, showBorder: false)
          : _itemContainer(item)
    ).toList();
    return headerItem != null
      ? [
          _itemContainer(
            Row(
              children: [headerItem!]
            ),
            padding: PharMeTheme.mediumSpace,
            showBorder: false,
          ),
          ...body,
        ]
      : body;
  }
}

class ContextMenuCheckmark extends StatelessWidget {
  const ContextMenuCheckmark(
      {super.key,
      required this.label,
      required this.setState,
      this.initialState = false});

  final String label;
  final void Function({ required bool value }) setState;
  final bool initialState;

  @override
  Widget build(BuildContext context) {
    var state = initialState;
    return StatefulBuilder(
      builder: (context, rebuild) => GestureDetector(
        onTap: () {
          rebuild(() {
            state = !state;
            setState(value: state);
          });
        },
        child: Row(
          children: [
            if (state)
              Icon(Icons.check_box, size: PharMeTheme.mediumSpace)
            else
              Icon(Icons.check_box_outline_blank, size: PharMeTheme.mediumSpace),
            SizedBox(width: PharMeTheme.smallSpace),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
