import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

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

  @override
  String? preparationErrorMessage(BuildContext context) =>
    context.l10n.err_fetch_user_data_failed;

  @override
  Future<void> prepareDataLoad() async {
    const clientId = 'pharme-app';
    const callbackUrlScheme = 'localhost';
    final url = authUrl.replace(queryParameters: {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': '$callbackUrlScheme:/',
      'scope': 'openid profile',
    });
    try {
      final result = await FlutterWebAuth.authenticate(
        url: url.toString(),
        callbackUrlScheme: callbackUrlScheme,
      );
      final code = Uri.parse(result).queryParameters['code'];
      final response = await http.post(tokenUrl, body: {
        'client_id': clientId,
        'redirect_uri': '$callbackUrlScheme:/',
        'grant_type': 'authorization_code',
        'code': code,
      });
      token = jsonDecode(response.body)['access_token'] as String;
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') {
        throw LabProcessCanceled();
      }
    }
    if (token == null) {
      throw LabAuthenticationError();
    }
  }
  
  @override
  Future<(List<LabResult>, List<String>)> loadData() async {
    return Lab.fetchData(dataUrl, headers: {'Authorization': 'Bearer $token'});
  }
}