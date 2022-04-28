import 'package:flutter/material.dart';

import '../../common/models/userdata.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

// ignore: flutter_style_todos
// TODO: remind me to remove this, for debugging only!
  String debug() {
    // ignore: prefer_single_quotes
    return """
    ${UserData.instance.diplotypes?[0].gene}
    ${UserData.instance.diplotypes?.length}

    ${UserData.instance.lookups?.length}
    ${UserData.instance.lookups?[0].keys.first} : ${UserData.instance.lookups?[0].values.first}

    """;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(debug()),
    );
  }
}
