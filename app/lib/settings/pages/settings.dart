import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../common/module.dart';
import '../../common/routing/router.dart';
import '../utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Card(
        child: ListTile(
          leading: Icon(Icons.delete),
          title: Text(context.l10n.settings_page_delete_data),
          trailing: Icon(Icons.chevron_right),
          onTap: () => showDialog(
            context: context,
            builder: (_) => _deleteDataDialog(context),
          ),
        ),
      ),
    ]);
  }

  Widget _deleteDataDialog(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.settings_page_delete_data),
      content: Text(context.l10n.settings_page_delete_data_text),
      actions: [
        TextButton(
          onPressed: context.router.root.pop,
          child: Text(context.l10n.settings_page_cancel),
        ),
        TextButton(
          onPressed: () async {
            await deleteAllAppData();
            await context.router.replaceAll([LoginRouter()]);
          },
          child: Text(context.l10n.settings_page_continue),
        ),
      ],
    );
  }
}
