import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../profile/models/hive/alleles.dart';

Future<String> authenticate(String authUrl) async {
  // 'http://172.20.24.129:28080/auth/realms/pharme'
  final uri = Uri.parse(authUrl);
  const clientId = 'pharme-app';
  final scopes = List<String>.of(['openid', 'profile']);
  const port = 4200;

  final issuer = await Issuer.discover(uri);
  final client = Client(issuer, clientId);

  final authenticator = Authenticator(
    client,
    scopes: scopes,
    port: port,
    urlLancher: (url) async {
      if (await canLaunch(url)) {
        await launch(url, forceWebView: true);
      } else {
        throw Exception('Could not launch $url');
      }
    },
  );
  final credentials = await authenticator.authorize();
  await closeWebView();
  return credentials.getTokenResponse().then((res) => res.accessToken ?? '');
}

Future<void> fetchAndSaveAllesData(String token, String url) async {
  final userData = Hive.box<Alleles>('userData');
  // TODO(toalaah): handle other response types (ex: 401, ...)
  if (userData.get('alleles') == null) {
    final response = await getStarAlleles(token, url);
    if (response.statusCode == 200) {
      await saveAlleleData(response, 'userData');
    }
  }
}

Future<http.Response> getStarAlleles(String? token, String url) async {
  final response = await http.get(
      // 127.0.0.1 - ios 'http://10.0.2.2:3000/api/v1/users/star-alleles'
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      });
  return response;
}

Future<void> saveAlleleData(http.Response response, String boxname) async {
  final json = jsonDecode(response.body);
  final alleles = Alleles.fromJson(json);
  return Hive.box<Alleles>('userData').put('alleles', alleles);
}
