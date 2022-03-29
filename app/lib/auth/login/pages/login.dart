import 'package:auto_route/auto_route.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  String dropdownValue = 'Illumina Solutions Center Berlin';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginPageCubit(),
      child: BlocBuilder<LoginPageCubit, LoginPageState>(
        builder: (context, state) {
          return state.when(
            initial: () => _buildInitialScreen(context),
            loadingAlleles: () => _buildLoadingScreen(context),
            loadedAlleles: () => _buildLoadedScreen(context),
            error: (message) => _buildErrorScreen(context, message),
          );
        },
      ),
    );
  }

  Widget _buildInitialScreen(BuildContext context) {
    return _basicWidgetTree(
      children: [
        DropdownButton(
          value: dropdownValue,
          icon: Icon(Icons.keyboard_arrow_down),
          items: labs
              .map((items) =>
                  DropdownMenuItem(value: items.name, child: Text(items.name)))
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
              final found = labs.firstWhere((el) => el.name == dropdownValue);
              await context
                  .read<LoginPageCubit>()
                  .signInAndLoadAlleles(found.authUrl, found.allelesUrl);
            },
            child: Text(context.l10n.auth_sign_in),
          ),
        )
      ],
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return _basicWidgetTree(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: RadiantGradientMask(
            colors: [
              context.theme.colorScheme.primaryContainer,
              context.theme.colorScheme.secondaryContainer,
            ],
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedScreen(BuildContext context) {
    return _basicWidgetTree(
      children: [
        RadiantGradientMask(
          colors: [
            context.theme.colorScheme.primaryContainer,
            context.theme.colorScheme.secondaryContainer,
          ],
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
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return _basicWidgetTree(
      children: [
        RadiantGradientMask(
          colors: [
            context.theme.colorScheme.primaryContainer,
            context.theme.colorScheme.secondaryContainer,
          ],
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
              context.read<LoginPageCubit>().emit(LoginPageState.initial());
            },
            child: Text('Retry'),
          ),
        ),
      ],
    );
  }

  Widget _basicWidgetTree({required List<Widget> children}) {
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
