import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete App Data'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => showDialog(
              context: context,
              builder: (_) => _deleteDataDialog(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _deleteDataDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Delete App Data'),
      content:
          Text('Are you sure that you really want to delete all app data?'),
      actions: [
        TextButton(
          onPressed: context.router.root.pop,
          child: Text('Cancel'),
        ),
        TextButton(onPressed: () {}, child: Text('Continue')),
      ],
    );
  }
}
