import 'package:flutter/material.dart';
import '../../common/module.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(context.l10n.nav_profile),
    );
  }
}
