import 'package:flutter/services.dart';
//import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../../common/module.dart';
import 'lab.dart';

class OAuthAuthorizationCodeFlowLab extends Lab {
  OAuthAuthorizationCodeFlowLab({
    required super.name,
    required this.authUrl,
    required this.tokenUrl,
    required this.dataUrl,
  });

  Uri authUrl;
  Uri tokenUrl;
  Uri dataUrl;

  late String? token;
  final _appAuth = FlutterAppAuth();

  @override
  Future<void> authenticate() async {
    const clientId = 'pharme-app';
    const callbackUrlScheme = 'localhost';
    final url = authUrl.replace(queryParameters: {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': '$callbackUrlScheme:/',
      'scope': 'openid profile',
    });
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          '$callbackUrlScheme:/', // your redirect URI
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: url.toString(), // your auth URL
            tokenEndpoint: tokenUrl.toString(), // your token URL
          ),
          scopes: <String>['openid', 'profile'], // adjust your scopes
        ),
      );

      token = result?.accessToken;
    } on PlatformException catch (e) {
      if (e.code == 'user_cancelled_authorization') {
        throw LabAuthenticationCanceled();
      } else {
        throw LabAuthenticationError();
      }
    }

    if (token == null) {
      throw LabAuthenticationError();
    }

    // use `token`…
  }

  @override
  Future<(List<LabResult>, List<String>)> loadData() async {
    return Lab.fetchData(dataUrl, headers: {'Authorization': 'Bearer $token'});
  }
}
