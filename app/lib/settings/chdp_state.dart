import 'package:flutter/services.dart';

import '../common/module.dart';

class ChdpListTile extends StatefulWidget {
  const ChdpListTile({Key? key}) : super(key: key);

  @override
  State<ChdpListTile> createState() => _ChdpState();
}

class _ChdpState extends State<ChdpListTile> with WidgetsBindingObserver {
  static const platform = MethodChannel('chdp');

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getIsLoggedIn().whenComplete(() => null);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getIsLoggedIn().whenComplete(() => null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLoggedIn
        ? Text('Log out of Smart4Health')
        : Text('Log in to Smart4Health');

    return ListTile(
      title: title,
      trailing: _isLoggedIn ? null : Icon(Icons.chevron_right),
      onTap: () => {
        // are you okay intellij autoformatter????
        if (_isLoggedIn)
          {logout().whenComplete(getIsLoggedIn)}
        else
          {login().whenComplete(() => null)}
      },
    ); // ListTile
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

  Future<void> login() async {
    try {
      await platform.invokeMethod('login');
    } on PlatformException catch (e) {
      debugPrint('platform exception in login');
    }
  }

  Future<void> logout() async {
    try {
      await platform.invokeMethod('logout');
    } on PlatformException catch (e) {
      debugPrint('platform exception in logout');
    }
  }
}
