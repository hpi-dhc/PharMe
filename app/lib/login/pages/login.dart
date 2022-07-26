import 'package:dropdown_button2/dropdown_button2.dart';

import '../../../common/module.dart';
import '../models/lab.dart';
import 'cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String dropdownValue = labs.first.name;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginPageCubit(),
      child: BlocBuilder<LoginPageCubit, LoginPageState>(
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/images/pharme_logo_horizontal.svg',
                      ),
                    ),
                  ),
                  Positioned(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: state.when(
                          initial: () => _buildInitialScreen(context),
                          loadingUserData: CircularProgressIndicator.new,
                          loadedUserData: () => _buildLoadedScreen(context),
                          error: (message) =>
                              _buildErrorScreen(context, message),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialScreen(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton2(
            isExpanded: true,
            dropdownOverButton: true,
            hint: Text(context.l10n.auth_choose_lab),
            value: dropdownValue,
            onChanged: (value) {
              setState(() {
                dropdownValue = value.toString();
              });
            },
            items: labs
                .map((lab) => DropdownMenuItem(
                      value: lab.name,
                      child: Text(lab.name),
                    ))
                .toList(),
            buttonPadding: const EdgeInsets.only(left: 16, right: 16),
            buttonDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.black26),
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
              final selectedLab = labs.firstWhere(
                (el) => el.name == dropdownValue,
              );
              await context
                  .read<LoginPageCubit>()
                  .signInAndLoadUserData(context, selectedLab);
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            child: Text(context.l10n.auth_sign_in),
          ),
        )
      ],
    );
  }

  Widget _buildLoadedScreen(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 96,
        ),
        SizedBox(height: 16),
        Text(
          context.l10n.auth_success,
          style: context.textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.router.replace(MainRoute()),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            child: Text(context.l10n.general_continue),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: Colors.red,
          size: 96,
        ),
        SizedBox(height: 16),
        Text(
          message,
          style: context.textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                context.read<LoginPageCubit>().revertToInitialState(),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            child: Text(context.l10n.general_retry),
          ),
        ),
      ],
    );
  }
}
