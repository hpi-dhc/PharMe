import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

import '../../module.dart';
import '../../utilities/hive_utils.dart';

part 'userdata.g.dart';

const _boxName = 'userdata';

class PhenotypeInformation {
  PhenotypeInformation({
    required this.phenotype,
    this.adaptionText,
    this.overwrittenPhenotypeText,
  });

  String phenotype;
  String? adaptionText;
  String? overwrittenPhenotypeText;
}

/// UserData is a singleton data-class which contains various user-specific
/// data It is intended to be loaded from a Hive box once at app launch, from
/// where it's contents can be modified by accessing it's properties.
@HiveType(typeId: 3)
class UserData {
  factory UserData() => _instance;

  // private constructor
  UserData._();

  static UserData _instance = UserData._();
  static UserData get instance => _instance;

  /// Writes the current instance to local storage
  static Future<void> save() async =>
      Hive.box<UserData>(_boxName).put('data', _instance);

  static Future<void> erase() async {
    _instance = UserData._();
    await UserData.save();
  }

  @HiveField(0)
  List<GeneResult>? geneResults;

  @HiveField(1)
  List<CpicLookup>? lookups;

  // hive can't deal with sets so we have to use a list :(
  @HiveField(2)
  List<String>? activeDrugNames;

  static List<Genotype>? _genotypesFrom(
    List<Genotype>? genotypes,
    String gene,
    [String? variant]
  ) {
    if (genotypes == null) return null;
    final matchingGenotypes = genotypes.where(
      (geneResult) => geneResult.gene == gene &&
        (variant == null || geneResult.variant == variant)
    ).toList();
    if (matchingGenotypes.isEmpty) {
      throw Exception(
        'Could not find Genotype for $gene, $variant'
      );
    }
    return matchingGenotypes;
  }

  static Genotype? _genotypeFrom(
    List<Genotype>? genotypes,
    Genotype genotype
  ) {
    final matchingGenotypes =
      _genotypesFrom(genotypes, genotype.gene, genotype.variant);
    if (matchingGenotypes != null && matchingGenotypes.length != 1) {
      throw Exception(
        'Found more than one Genotype for ${genotype.toString()} but should '
        'only find one'
      );
    }
    return matchingGenotypes?.first;
  }

  static GeneResult? _geneResultFor(Genotype genotype) =>
    _genotypeFrom(UserData.instance.geneResults, genotype) as GeneResult?;

  static List<GeneResult>? _geneResultsFor(String gene) =>
    _genotypesFrom(UserData.instance.geneResults, gene) as List<GeneResult>?;

  static List<CpicLookup>? _lookupkeysFor(String gene) =>
    _genotypesFrom(UserData.instance.lookups, gene) as List<CpicLookup>?;

  static String? variantFor(Genotype genotype) =>
    _geneResultFor(genotype)?.variant;

  static String? allelesTestedFor(Genotype genotype) =>
    _geneResultFor(genotype)?.allelesTested;

  static Genotype? genotypeFor(
    String gene,
    Drug drug,
    { required bool useOverwrite }
  ) {
    final overwrite = useOverwrite
      ? UserData.overwrittenLookup(gene, drug: drug.name)
      : null;
    if (overwrite != null) {
      return Genotype(gene: gene, variant: overwrite.value);
    }
    final matchingGeneResults = _geneResultsFor(gene);
    if (matchingGeneResults == null) return null;
    if (matchingGeneResults.length == 1) {
      return Genotype(
        gene: gene,
        variant: matchingGeneResults.first.variant,
      );
    }
    // When multiple lookups were found it means that the gene has positive/
    // negative results for multiple alleles; return the lookup that matches
    // the allele
    final guidelineAlleles = drug.userGuideline?.lookupkey[gene]?.map(
      (lookupkey) => lookupkey.split(' ').first
    ).toSet();
    if (guidelineAlleles == null || guidelineAlleles.length != 1) return null;
    final variant = matchingGeneResults.firstWhere(
      (geneResult) => geneResult.variant.startsWith(guidelineAlleles.first)
    ).variant;
    return Genotype(gene: gene, variant: variant);
  }

  static List<String>? lookupkeysFor(
    String gene,
    {
      String? drug,
      bool useOverwrite = true,
    }
  ) {
    final overwrittenLookup = UserData.overwrittenLookup(gene, drug: drug);
    final matchingLookups = _lookupkeysFor(gene);
    return matchingLookups?.map(
      (lookup) => (useOverwrite && overwrittenLookup != null)
        ? overwrittenLookup.value
        : lookup.lookupkey
    ).toList();
  }

  static MapEntry<String, String>? overwrittenLookup(
    String gene,
    { String? drug }
  ) {
    final inhibitors = strongDrugInhibitors[gene];
    if (inhibitors == null) return null;
    final lookup = inhibitors.entries.firstWhereOrNull((entry) {
      final isActiveInhitor =
        UserData.instance.activeDrugNames?.contains(entry.key) ?? false;
      final wouldInhibitItself = drug == entry.key;
      return isActiveInhitor && !wouldInhibitItself;
    });
    if (lookup == null) return null;
    return lookup;
  }

  static List<String> activeInhibitorsFor(String gene, { String? drug }) {
    return UserData.instance.activeDrugNames == null
      ? <String>[]
      : UserData.instance.activeDrugNames!.filter(
          (activeDrug) =>
            inhibitorsFor(gene).contains(activeDrug) &&
            activeDrug != drug
        ).toList();
  }

  // TODO: revisit all the data types and their usage again; can we make this
  // less redundant? Can we safely assume that binary gene results cannot be
  // inhibited and what would change then?
  // TODO(me): should probably receive geneResult already (otherwise not clear)
  // if should use overwrite
  static PhenotypeInformation phenotypeInformationFor(
    Genotype? genotype,
    BuildContext context,
    {
      String? drug,
      bool thirdPerson = false,
      bool useLongPrefix = false,
    }
  ) {
    final missingResult = PhenotypeInformation(
        phenotype: context.l10n.general_not_tested,
      );
    if (genotype == null) return missingResult;
    final originalPhenotype = _geneResultFor(genotype)?.phenotype;
    if (originalPhenotype == null) return missingResult;
    final userSalutation = thirdPerson
      ? context.l10n.drugs_page_inhibitor_third_person_salutation
      : context.l10n.drugs_page_inhibitor_direct_salutation;
    final strongInhibitorTextPrefix = useLongPrefix
      ? context.l10n.strong_inhibitor_long_prefix
      : context.l10n.gene_page_phenotype.toLowerCase();
    final activeInhibitors =
      UserData.activeInhibitorsFor(genotype.gene, drug: drug);
    if (activeInhibitors.isEmpty) {
      return PhenotypeInformation(phenotype: originalPhenotype);
    }
    final overwritePhenotype = context.l10n.general_poor_metabolizer;
    final currentPhenotypeEqualsOverwritePhenotype =
      originalPhenotype.toLowerCase() == overwritePhenotype.toLowerCase();
    if (currentPhenotypeEqualsOverwritePhenotype) {
      return PhenotypeInformation(
        phenotype: originalPhenotype,
      );
    }
    final overwrittenLookup =
      UserData.overwrittenLookup(genotype.gene, drug: drug);
    if (overwrittenLookup == null) {
      return PhenotypeInformation(
        phenotype: originalPhenotype,
        adaptionText: context.l10n.drugs_page_moderate_inhibitors(
          userSalutation,
          enumerationWithAnd(
            activeInhibitors,
            context
          ),
        ),
      );
    }
    final originalPhenotypeText = context.l10n.drugs_page_original_phenotype(
      thirdPerson
        ? context.l10n.drugs_page_inhibitor_third_person_salutation_genitive
        : context.l10n.drugs_page_inhibitor_direct_salutation_genitive,
      originalPhenotype,
    );
    return PhenotypeInformation(
      phenotype: overwritePhenotype,
      adaptionText: context.l10n.drugs_page_strong_inhibitors(
          strongInhibitorTextPrefix,
          userSalutation,
          enumerationWithAnd(activeInhibitors, context),
        ),
      overwrittenPhenotypeText: originalPhenotypeText,
    );
  }
}

// Wrapper of UserData.instance.activeDrugNames that manages changes; used to
// notify inactive tabs in case of changes. Should be refacored to ensure
// consistent use accross the app, see
// https://github.com/hpi-dhc/PharMe/issues/680
class ActiveDrugs extends ChangeNotifier {
  ActiveDrugs() {
    names = UserData.instance.activeDrugNames ?? [];
  }
  late List<String> names;

  Future<void> _preserveAndNotify() async {
    UserData.instance.activeDrugNames = names;
    await UserData.save();
    notifyListeners();
  }

  Future<void> setList(List<String> drugNames) async {
    names = drugNames;
    await _preserveAndNotify();
  }

  Future<void> _add(String drugName) async {
    names.add(drugName);
    await _preserveAndNotify();
  }

  Future<void> _remove(String drugName) async {
    names = names.filter((name) => name != drugName).toList();
    await _preserveAndNotify();
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> changeActivity(String drugName, bool value) async {
    if (value) {
      await _add(drugName);
    } else {
      await _remove(drugName);
    }
  }

  bool contains(String drugName) {
    return names.contains(drugName);
  }

  bool isNotEmpty() {
    return names.isNotEmpty;
  }
}

/// Initializes the user's data by registering all necessary adapters and
/// loading pre-existing data from local storage, if it exists.
Future<void> initUserData() async {
  // We only want to register the necessary adapters once. If it has already been
  // registered, we return early as to avoid overwriting changed data from the
  // session which has not yet been written to local storage.
  try {
    Hive.registerAdapter(UserDataAdapter());
    Hive.registerAdapter(GeneResultAdapter());
    Hive.registerAdapter(CpicLookupAdapter());
  } catch (e) {
    return;
  }

  final encryptionKey = await retrieveExistingOrGenerateKey();
  // if user's metadata is not null, assign it's contents to the singleton
  await Hive.openBox<UserData>(
    _boxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  final userData = Hive.box<UserData>(_boxName);
  UserData._instance = userData.get('data') ?? UserData();
}

// assumes http reponse from lab server
List<String> activeDrugsFromHTTPResponse(Response resp) {
  var activeDrugs = <String>[];
  final json = jsonDecode(resp.body) as Map<String, dynamic>;
  if (json.containsKey('medications')) {
    activeDrugs = List<String>.from(json['medications']);
  }
  return activeDrugs;
}
