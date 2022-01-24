import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

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
