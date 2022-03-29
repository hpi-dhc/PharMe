import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../common/module.dart';
import '../../../common/routing/router.dart';
import '../../../common/widgets/radiant_gradiant_mask.dart';
import '../models/lab.dart';
import 'cubit.dart';

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
      '${dotenv.env['BACKEND_URL']}/api/v1/star-alleles',
    ),
    Lab(
      'Mount Sinai Hospital (NYC)',
      'http://172.20.24.66:28080/auth/realms/pharme',
      '${dotenv.env['BACKEND_URL']}/api/v1/star-alleles',
    )
  ];
  String dropdownValue = 'Illumina Solutions Center Berlin';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginPageCubit(),
      child: BlocBuilder<LoginPageCubit, LoginPageState>(
        builder: (context, state) {
          return state.when(
            initial: () => _buildStatusScreen(
              context: context,
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
                SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final found =
                          labs.firstWhere((el) => el.name == dropdownValue);
                      await context
                          .read<LoginPageCubit>()
                          .signInAndLoadData(found.authUrl, found.allelesUrl);
                    },
                    child: Text(context.l10n.auth_sign_in),
                  ),
                ),
              ],
            ),
            loadingAlleles: () => _buildStatusScreen(
              context: context,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: RadiantGradientMask(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            loadedAlleles: () => _buildStatusScreen(
              context: context,
              children: [
                RadiantGradientMask(
                  child: Icon(
                    Icons.task_alt,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
                Text('Successfully imported data'),
                SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.router.replace(MainRoute()),
                    child: Text('Continue'),
                  ),
                ),
              ],
            ),
            error: (message) => _buildStatusScreen(
              context: context,
              children: [
                RadiantGradientMask(
                  child: Icon(
                    Icons.warning_amber_outlined,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
                Text(message),
                SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<LoginPageCubit>()
                          .emit(LoginPageState.initial());
                    },
                    child: Text('Retry'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusScreen({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}
