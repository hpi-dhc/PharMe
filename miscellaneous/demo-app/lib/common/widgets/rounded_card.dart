import 'package:flutter/material.dart';

class RoundedCard extends StatelessWidget {
  RoundedCard({
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    required this.child,
  });

  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Widget child;

  final borderRadius = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  );

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(padding: padding, child: this.child);

    if (onTap != null) child = InkWell(onTap: onTap, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        // TODO(kolioOtSofia): adjust to theme colors when merged)
        color: Color(0xFFF9F9F9),
        border: Border.all(width: 0.5, color: Colors.black.withOpacity(0.2)),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
