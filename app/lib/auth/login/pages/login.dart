import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../profile/models/alleles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  List<String> labs = ['Illumina Solutions Center Berlin', 'Mount Sinai Hospital (NYC)'];
  String dropdownValue = 'Illumina Solutions Center Berlin';

  Future<TokenResponse> authenticate() async {
    // parameters here just for the sake of the question
    final uri = Uri.parse('http://172.20.24.129:28080/auth/realms/pharme');
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

    final c = await authenticator.authorize();
    await closeWebView();

    final token = await c.getTokenResponse();
    final prefs = await EncryptedSharedPreferences().getInstance();
    final localData = prefs.getString('allData');
    final tokenString = token.accessToken;

    // TODO(toalaah): refactor to external method
    // TODO(toalaah): move all constant urls to some global file
    if (localData == null) {
      final response = await http.get(Uri.parse('http://127.0.0.1:3000/api/v1/users/star-alleles'),
        headers: <String, String>{
          'Authorization': 'Bearer $tokenString',
        });

      // TODO(toalaah): handle other response types (ex: 401, ...)
      if (response.statusCode == 200) {
        // print('all good from api');
        final allData = Alleles.fromJson(jsonDecode(response.body)); // mock api call
        await prefs.setString('allData', jsonEncode(allData));
      }
      // print('got from api');
    } else {
      // print('got from local');
    }

    final alleleData = Alleles.fromJson(jsonDecode(prefs.getString('allData') ?? ''));

    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButton(
                value: dropdownValue,
                icon: Icon(Icons.keyboard_arrow_down),
                items: labs
                    .map((items) =>
                        DropdownMenuItem(value: items, child: Text(items)))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    dropdownValue = newValue.toString();
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  await authenticate();
                  await context.router.replaceNamed('main/medications');
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
