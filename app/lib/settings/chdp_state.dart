import 'package:flutter/services.dart';

import '../common/module.dart';

class ChdpListTile extends StatefulWidget {
  const ChdpListTile({Key? key}) : super(key: key);

  @override
  State<ChdpListTile> createState() => _ChdpState();
}

class _ChdpState extends State<ChdpListTile> {
  static const platform = MethodChannel('chdp');

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    getIsLoggedIn().whenComplete(() => null);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Is logged in? $_isLoggedIn'),
    );
  }

  Future<void> getIsLoggedIn() async {
    var isLoggedIn = false;
    try {
      isLoggedIn = await platform.invokeMethod('isLoggedIn');
    } on PlatformException catch (e) {
      debugPrint('platform exception in getIsLoggedIn');
    }

    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }
}
