import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';

import '../../../common/module.dart';
import '../cubit.dart';
import '../models/dummy_demo_lab.dart';
import '../models/cpic_lab.dart';

final labs = [
  DummyDemoLab(
    name: 'Mount Sinai Health System',
    dataUrl: Uri.parse(
      'https://hpi-datastore.duckdns.org/userdata?id=66608824-2ab4-4f03-aef0-03aa007337d3',
    ),
  ),
  CpicLab(name: 'Choose your VCF file'),
];

@RoutePage()
class LoginPage extends HookWidget {
  const LoginPage({
    super.key,
    @visibleForTesting this.cubit,
  });

  final LoginCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final dropdownValue = useState(labs.first.name);

    return Consumer<ActiveDrugs>(
        builder: (context, activeDrugs, child) => BlocProvider(
              create: (context) => cubit ?? LoginCubit(activeDrugs),
              child: BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  return PharMeLogoPage(
                    child: state.when(
                      initial: () =>
                          _buildInitialScreen(context, dropdownValue),
                      loadingUserData: (loadingMessage) => Padding(
                        padding: EdgeInsets.all(PharMeTheme.largeSpace),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            if (loadingMessage != null) ...[
                              SizedBox(height: PharMeTheme.largeSpace),
                              Text(
                                loadingMessage,
                                style: context.textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                      loadedUserData: () => _buildLoadedScreen(context),
                      error: (message) => _buildErrorScreen(context, message),
                    ),
                  );
                },
              ),
            ));
  }

  Widget _buildInitialScreen(
    BuildContext context,
    ValueNotifier<String> dropdownValue,
  ) {
    Future<void> action() async {
      final selectedLab = labs.firstWhere(
        (el) => el.name == dropdownValue.value,
      );
      await context
          .read<LoginCubit>()
          .signInAndLoadUserData(context, selectedLab);
    }

    return _buildColumnWrapper(
      action: action,
      actionText: context.l10n.auth_sign_in,
      children: [
        Text(
          context.l10n.auth_welcome,
          style: PharMeTheme.textTheme.titleLarge,
        ),
        SizedBox(height: PharMeTheme.smallSpace),
        Text(
          context.l10n.auth_choose_lab,
          style: PharMeTheme.textTheme.titleMedium,
        ),
        SizedBox(height: PharMeTheme.mediumSpace),
        DropdownButtonHideUnderline(
          child: DropdownButton2(
            isExpanded: true,
            dropdownStyleData: DropdownStyleData(
              isOverButton: true,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            hint: Text(context.l10n.auth_choose_lab),
            value: dropdownValue.value,
            onChanged: (value) {
              dropdownValue.value = value.toString();
            },
            items: labs
                .map((lab) => DropdownMenuItem(
                      value: lab.name,
                      child: Text(lab.name),
                    ))
                .toList(),
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: PharMeTheme.borderColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedScreen(BuildContext context) {
    return _buildColumnWrapper(
      action: () => overwriteRoutes(
        context,
        nextPage: OnboardingRoute(),
      ),
      actionText: context.l10n.general_continue,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          color: PharMeTheme.primaryColor,
          size: 96,
        ),
        SizedBox(height: PharMeTheme.mediumSpace),
        Text(
          context.l10n.auth_success,
          style: context.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return _buildColumnWrapper(
      action: () => context.read<LoginCubit>().revertToInitialState(),
      actionText: context.l10n.general_retry,
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: PharMeTheme.errorColor,
          size: 96,
        ),
        SizedBox(height: PharMeTheme.mediumSpace),
        Text(
          message,
          style: context.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildColumnWrapper({
    required void Function()? action,
    required String actionText,
    required List<Widget> children,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...children,
        SizedBox(height: PharMeTheme.mediumSpace),
        FullWidthButton(actionText, action ?? () {}),
        SizedBox(height: PharMeTheme.mediumSpace),
      ],
    );
  }
}
