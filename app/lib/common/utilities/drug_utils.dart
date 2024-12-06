import 'dart:convert';
import 'package:http/http.dart';

import '../../app.dart';
import '../module.dart';

List<GenotypeResult> getInhibitedGenotypesForDrug(Drug drug) {
  final genotypeResults = getGenotypeResultsForDrug(drug);
  return genotypeResults?.filter(
    (genotypeResult) => isInhibited(genotypeResult, drug: drug.name)
  ).toList() ?? [];
}

List<GenotypeResult>? getGenotypeResultsForDrug(Drug drug) {
  if (drug.userGuideline == null && drug.guidelines.isEmpty) {
    return null;
  }
  return drug.guidelineGenotypes.map((genotypeKey) =>
    UserData.instance.genotypeResults![genotypeKey] ??
      // Should not be null but to be safe
      GenotypeResult.missingResult(
        GenotypeKey.extractGene(genotypeKey),
        variant: GenotypeKey.maybeExtractVariant(genotypeKey),
      )
  ).toList();
}

Future<void> maybeUpdateDrugsWithGuidelines() async {
  final isOnline = await hasConnectionTo(anniUrl().host);
  if (!isOnline && DrugsWithGuidelines.instance.version == null) {
    throw Exception();
  }
  final versionResponse = await get(anniUrl('version'));
  if (versionResponse.statusCode != 200) throw Exception();
  final version = AnniVersionResponse.fromJson(jsonDecode(versionResponse.body))
      .data
      .version;
  if (version == DrugsWithGuidelines.instance.version) return;
  final dataResponse = await get(anniUrl('data'));
  if (dataResponse.statusCode != 200) throw Exception();
  final data = AnniDataResponse.fromJson(jsonDecode(dataResponse.body)).data;
  final previousVersion = DrugsWithGuidelines.instance.version;
  DrugsWithGuidelines.instance.drugs = data.drugs;
  DrugsWithGuidelines.instance.version = data.version;
  await DrugsWithGuidelines.save();
  await maybeUpdateGenotypeResults();
  if (previousVersion != null) {
    final context = PharMeApp.navigatorKey.currentContext;
    if (context != null) {
      await showAdaptiveDialog(
      // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => DialogWrapper(
          title: context.l10n.update_warning_title,
          content: DialogContentText(context.l10n.update_warning_body),
          actions: [
            DialogAction(
              onPressed: () => Navigator.pop(context),
              text: context.l10n.action_understood,
            ),
          ],
        ),
      );
    }
  }
}
