import 'package:flutter/material.dart';

import '../../common/module.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(context.l10n.reports_page_text),
    );
  }
}
