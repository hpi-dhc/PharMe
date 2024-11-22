import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';

import '../../../common/module.dart';
import '../cubit.dart';
import '../models/deep_link_share_flow_lab.dart';
import '../models/dummy_demo_lab.dart';
import '../models/lab.dart';

final labs = [
  DummyDemoLab(
    name: 'Charité',
    dataUrl: Uri.parse(
      'https://hpi-datastore.duckdns.org/userdata?id=66608824-2ab4-4f03-aef0-03aa007337d3',
    ),
  )
];

final healthXLab = DeepLinkShareFlowLab(
    name: 'HEALTH-X dataLOFT',
    shareAppName: 'Consent Manager App',
);

@RoutePage()
class LoginPage extends HookWidget {
  const LoginPage({
    super.key,
    this.initialState,
    @visibleForTesting this.cubit,
  });

  final LoginCubit? cubit;
  final LoginState? initialState;

  Lab _getSelectedLab(ValueNotifier<String> dropdownValue) => labs.firstWhere(
    (lab) => lab.name == dropdownValue.value,
  );

  Future<void> _getDataFromLab(Lab lab, BuildContext context) async => context
    .read<LoginCubit>()
    .signInAndLoadUserData(context, lab);

  @override
  Widget build(BuildContext context) {
    final dropdownValue = useState(labs.first.name);

    return Consumer<ActiveDrugs>(
      builder: (context, activeDrugs, child) => BlocProvider(
        create: (context) => cubit ?? LoginCubit(activeDrugs, initialState),
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
                error: (message) =>
                    _buildErrorScreen(context, message),
              ),
            );
          },
        ),
      )
    );
  }

  Widget _buildInitialScreen(
    BuildContext context,
    ValueNotifier<String> dropdownValue,
  ) {
    return _buildColumnWrapper(
      action: () => _getDataFromLab(_getSelectedLab(dropdownValue), context),
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
      bottomWidget: Platform.isAndroid
        ? Column(
          children: _buildHealthXShareContent(context),
        )
        : null,
    );
  }

  List<Widget> _buildHealthXShareContent(BuildContext context) {
    final loadingPossible = MetaData.instance.deepLinkSharePublishUrl != null;
    return [
        FullWidthButton(
          'Import data from ${healthXLab.name}',
          () => _getDataFromLab(healthXLab, context),
          color: Colors.orange,
          enabled: loadingPossible,
        ),
        if (!loadingPossible) ...[
          SizedBox(height: PharMeTheme.smallSpace),
          Text(
            'Share your data with PharMe using the ${healthXLab.shareAppName}, '
            'and return to PharMe to import them.',
            style: PharMeTheme.textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ]
      ];
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
    Widget? bottomWidget,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...children,
        SizedBox(height: PharMeTheme.smallSpace),
        FullWidthButton(actionText, action ?? () {}),
        SizedBox(height: PharMeTheme.mediumSpace),
        if (bottomWidget != null) ...[
          bottomWidget,
          SizedBox(height: PharMeTheme.mediumSpace),
        ],
      ],
    );
  }
}
