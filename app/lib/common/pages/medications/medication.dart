// ignore_for_file: avoid_returning_null_for_void

import 'dart:io';

import 'package:flutter/services.dart';

import '../../../common/module.dart';
import '../../utilities/pdf_utils.dart';
import 'cubit.dart';
import 'widgets/module.dart';

class MedicationPage extends StatelessWidget {
  const MedicationPage(
    this.id, {
    @visibleForTesting this.cubit,
  });

  final int id;
  final MedicationsCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit ?? MedicationsCubit(id),
      child: BlocBuilder<MedicationsCubit, MedicationsState>(
        builder: (context, state) {
          return RoundedCard(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
            child: state.when(
              initial: Container.new,
              error: () => Text(context.l10n.err_generic),
              loading: () => Center(child: CircularProgressIndicator()),
              loaded: (medication) => _buildMedicationsPage(
                medication,
                context: context,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationsPage(
    MedicationWithGuidelines medication, {
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(medication, context),
        SizedBox(height: 20),
        Disclaimer(),
        SizedBox(height: 20),
        SubHeader(
          context.l10n.medications_page_header_guideline,
          tooltip: context.l10n.medications_page_tooltip_guideline,
        ),
        SizedBox(height: 12),
        if (medication.guidelines.isNotEmpty)
          ClinicalAnnotationCard(medication)
        else
          Text(context.l10n.medications_page_no_guidelines_for_phenotype),
      ],
    );
  }

  Widget _buildHeader(
      MedicationWithGuidelines medication, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(medication.name, style: PharMeTheme.textTheme.displaySmall),
            Row(
              children: [
                if (Platform.isAndroid)
                  IconButton(
                      onPressed: () async {
                        final isLoggedIn = await MethodChannel('chdp')
                            .invokeMethod('isLoggedIn');

                        if (isLoggedIn) {
                          await showDialog(
                              context: context,
                              builder: (_) =>
                                  _shouldUploadDialog(context, () async {
                                    final isSuccess =
                                        await sharePdfSmart4Health(medication);
                                    if (isSuccess) {
                                      await MethodChannel('chdp').invokeMethod(
                                          'toast',
                                          {'msg': 'Upload successful'});
                                    } else {
                                      await MethodChannel('chdp').invokeMethod(
                                          'toast', {'msg': 'Upload failed'});
                                    }
                                  }));
                        } else {
                          await showDialog(
                              context: context,
                              builder: (_) => _pleaseLogInDialog(context));
                        }
                      },
                      icon: Icon(
                        Icons.upload_file,
                        size: 32,
                        color: PharMeTheme.primaryColor,
                      ))
                else
                  null,
                IconButton(
                    onPressed: () => sharePdf(medication),
                    icon: Icon(
                      Platform.isAndroid ? Icons.share : Icons.ios_share,
                      size: 32,
                      color: PharMeTheme.primaryColor,
                    )),
              ].whereType<Widget>().toList(),
            ),
          ],
        ),
        if (medication.drugclass != null)
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: PharMeTheme.onSurfaceColor,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Text(
              medication.drugclass!,
              style: PharMeTheme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
      ],
    );
  }

  Widget _pleaseLogInDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Please log in'),
      content: Text(
          'To upload your report, please log in to Smart4Health under More > Account Settings'),
      actions: [
        TextButton(
          onPressed: context.router.root.pop,
          child: Text('Okay'),
        ),
      ],
    );
  }

  // intellij autoformatter having a normal one
  Widget _shouldUploadDialog(
      BuildContext context, Future<void> Function() onPositivePressed) {
    return AlertDialog(
        title: Text('Upload report'),
        content: Text('Would you like to upload your report to Smart4Health?'),
        actions: [
          TextButton(onPressed: context.router.root.pop, child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              await context.router.root.pop();
              await onPositivePressed();
            },
            child: Text('Upload'),
          )
        ]);
  }
}
