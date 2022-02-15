import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

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
      'http://172.20.24.129:28080/auth/realms/pharme',
      'http://10.0.2.2:3000/api/v1/users/star-alleles',
    ),
    Lab(
      'Mount Sinai Hospital (NYC)',
      'http://172.20.24.129:28080/auth/realms/pharme',
      'http://10.0.2.2:3000/api/v1/users/star-alleles',
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

class Lab {
  Lab(this.name, this.authUrl, this.allelesUrl);

  String name;
  String authUrl;
  String allelesUrl;
}
