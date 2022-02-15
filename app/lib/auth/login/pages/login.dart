import 'package:auto_route/auto_route.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SvgPicture.asset(
              'assets/images/pharme_logo_horizontal.svg',
            ),
            Column(
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    isExpanded: true,
                    hint: Text('Please select your lab'),
                    value: dropdownValue,
                    onChanged: (value) {
                      setState(() {
                        dropdownValue = value.toString();
                      });
                    },
                    items: labs
                        .map((lab) =>
                            DropdownMenuItem(value: lab, child: Text(lab)))
                        .toList(),
                    buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                    buttonDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                    ),
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await authenticate();

                      await context.router.pop();
                      await context.router.replaceNamed('main/medications');
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                    child: Text('Continue'),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<String> labs = [
  'Illumina Solutions Center Berlin',
  'Mount Sinai Hospital (NYC)'
];

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
  return c.getTokenResponse();
}
