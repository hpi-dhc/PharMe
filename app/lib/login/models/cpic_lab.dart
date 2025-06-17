import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pharmcat_dart_plugin/helper.dart';

import '../../common/module.dart';
import 'lab.dart';

class CpicLab extends Lab {
  CpicLab({
    required super.name,
  });

  @override
  Future<(List<LabResult>, List<String>)> loadData() async {
    try {
      final vcfType = XTypeGroup(
        label: 'All Files',
      );
      final XFile? picked = await openFile(
        acceptedTypeGroups: [vcfType],
      );
      if (picked == null) {
        // User canceled
        return (<LabResult>[], <String>[]);
      }
      final vcfPath = picked.path;

      // 2) Decide where to save the phenotype JSON
      final dir = await getApplicationSupportDirectory();
      final phenotypeOutputPath = path.join(
        dir.path,
        'phenotyper.json',
      );

      // 3) Generate it
      final (success, rawJson) = await Helper.processFile(
        vcfPath,
        phenotypeOutputPath,
      );
      if (!success) {
        throw LabAuthenticationError();
      }

      final raw = rawJson;

      final Map<String, dynamic> doc = json.decode(raw) as Map<String, dynamic>;

      final cpic = (doc['geneReports'] as Map<String, dynamic>?)?['CPIC']
              as Map<String, dynamic>? ??
          <String, dynamic>{};

      final List<LabResult> labData = [];

      for (final entry in cpic.entries) {
        //final geneKey = entry.key;
        final gm = entry.value as Map<String, dynamic>?;
        if (gm == null) {
          //print('[$geneKey] skipped: not a Map');
          continue;
        }

        final gene = gm['geneSymbol'] as String?;
        if (gene == null) {
          //print('[$geneKey] skipped: geneSymbol missing');
          continue;
        }

        final srcList = gm['sourceDiplotypes'] as List?;
        if (srcList == null || srcList.isEmpty) {
          //print('[$gene] skipped: no sourceDiplotypes');
          continue;
        }

        final src = srcList.first as Map<String, dynamic>?;
        if (src == null) {
          //print('[$gene] skipped: sourceDiplotypes[0] not a Map');
          continue;
        }

        final a1 = src['allele1'] as Map<String, dynamic>?;
        final a2 = src['allele2'] as Map<String, dynamic>?;
        if (a1 == null || a2 == null) {
          //print('[$gene] skipped: allele1/allele2 missing');
          continue;
        }
        final variant = '${a1['name'] ?? ''}/${a2['name'] ?? ''}';
        const allelesTested = '';

        final recList = gm['recommendationDiplotypes'] as List?;
        var phenotype = '';
        if (recList != null && recList.isNotEmpty) {
          final rec = recList.first as Map<String, dynamic>?;
          final phens = rec?['phenotypes'] as List?;
          if (phens != null && phens.isNotEmpty) {
            phenotype = phens.first as String;
          }
        }

        labData.add(LabResult(
          gene: gene,
          variant: variant,
          phenotype: phenotype,
          allelesTested: allelesTested,
        ));
      }

      return (labData, <String>[]);
    } catch (e) {
      throw LabAuthenticationError();
    }
  }
}
