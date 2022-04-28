import 'package:flutter/material.dart';

import '../../common/models/metadata.dart';
import '../../common/models/userdata.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

// ignore: flutter_style_todos
// TODO: remind me to remove this, for debugging only!
  String debug() {
    // ignore: prefer_single_quotes
    return """
    ${UserdataContainer.instance.data.diplotypes?[0].gene}
    ${UserdataContainer.instance.data.diplotypes?.length}

    ${UserdataContainer.instance.data.lookups?.length}
    ${UserdataContainer.instance.data.lookups?[0].keys.first} : ${UserdataContainer.instance.data.lookups?[0].values.first}

    ${MetadataContainer.instance.data.isLoggedIn}
    ${MetadataContainer.instance.data.lookupsLastFetchDate}
    """;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(debug()),
    );
  }
}
