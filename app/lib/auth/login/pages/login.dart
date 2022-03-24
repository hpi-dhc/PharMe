import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';

import '../../../common/module.dart';
import '../../../common/routing/router.dart';
import '../auth_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  List<Lab> labs = [
    Lab(
      'Illumina Solutions Center Berlin',
      'http://172.20.24.66:28080/auth/realms/pharme',
      '${dotenv.env['BACKEND_URL']}/api/v1/users/star-alleles',
    ),
    Lab(
      'Mount Sinai Hospital (NYC)',
      'http://172.20.24.66:28080/auth/realms/pharme',
      '${dotenv.env['BACKEND_URL']}/api/v1/users/star-alleles',
    )
  ];
  String dropdownValue = 'Illumina Solutions Center Berlin';

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
                    .map((items) => DropdownMenuItem(
                        value: items.name, child: Text(items.name)))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    dropdownValue = newValue.toString();
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final found =
                      labs.firstWhere((el) => el.name == dropdownValue);

                  final token = await authenticate(found.authUrl);
                  await fetchAndSaveAllesData(token, found.allelesUrl);
                  // Login Successful
                  await Hive.box('preferences').put('isLoggedIn', true);
                  await context.router.replace(const MainRoute());
                },
                child: Text(context.l10n.auth_sign_in),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Lab {
  Lab(this.name, this.authUrl, this.allelesUrl);

  String name;
  String authUrl;
  String allelesUrl;
}
