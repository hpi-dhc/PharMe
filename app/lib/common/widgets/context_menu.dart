import 'package:popover/popover.dart';

import '../module.dart';

class ContextMenu extends StatelessWidget {
  const ContextMenu({
    super.key,
    required this.items,
    required this.child,
  });

  final List<ContextMenuAction> items;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showPopover(
            context: context,
            bodyBuilder: (context) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: PharMeTheme.onSurfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items
                      .mapIndexed((index, item) => (index == items.count() - 1)
                          ? item
                          : Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                bottom: BorderSide(
                                    width: 0.5, color: PharMeTheme.borderColor),
                              )),
                              child: item))
                      .toList(),
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
}

class ContextMenuAction extends StatelessWidget {
  const ContextMenuAction({
    super.key,
    required this.label,
    required this.action,
    this.icon,
  });

  final String label;
  final void Function() action;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon!, size: 24) else SizedBox(width: 24),
            SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
