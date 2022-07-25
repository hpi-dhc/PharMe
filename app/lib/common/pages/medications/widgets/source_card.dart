import 'package:flutter/material.dart';

import '../../../theme.dart';

class SourceCard extends StatelessWidget {
  const SourceCard({
    required this.name,
    required this.description,
    required this.onTap,
  });

  final String name;
  final String description;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(colors: [
            PharmeTheme.primaryColor.withOpacity(0.8),
            PharmeTheme.secondaryColor.withOpacity(0.8),
          ]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
              flex: 3,
              child: Text(
                name,
                style: PharmeTheme.textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              flex: 10,
              child: Text(
                description,
                style: PharmeTheme.textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
