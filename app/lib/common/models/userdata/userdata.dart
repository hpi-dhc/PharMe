import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

import '../../module.dart';
import '../../utilities/hive_utils.dart';

part 'userdata.g.dart';

const _boxName = 'userdata';

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
  List<LabResult>? labData;
  @HiveField(1)
  // hive can't deal with sets so we have to use a list :(
  List<String>? activeDrugNames;
  @HiveField(2)
  Map<String, GenotypeResult>? genotypeResults;

  static PhenotypeInformation phenotypeInformationFor(
    GenotypeResult genotypeResult,
    BuildContext context,
    {
      String? drug,
      bool thirdPerson = false,
      bool useLongPrefix = false,
    }
  ) {
    final userSalutation = thirdPerson
      ? context.l10n.drugs_page_inhibitor_third_person_salutation
      : context.l10n.drugs_page_inhibitor_direct_salutation;
    final strongInhibitorTextPrefix = useLongPrefix
      ? context.l10n.strong_inhibitor_long_prefix
      : context.l10n.gene_page_phenotype.toLowerCase();
    final originalPhenotype = genotypeResult.phenotype;
    final activeInhibitors = UserData.activeInhibitorsFor(
      genotypeResult.gene,
      drug: drug,
    );
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
    final overwrittenLookup = UserData.overwrittenLookup(
      genotypeResult.gene,
      drug: drug,
    );
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

  static String? variantFor(String genotypeKey) =>
      UserData.instance.genotypeResults?[genotypeKey]?.variant;

  static String? allelesTestedFor(String genotypeKey) =>
      UserData.instance.genotypeResults?[genotypeKey]?.allelesTested;

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

  static String? lookupFor(
    String genotypeKey,
    {
      String? drug,
      bool useOverwrite = true,
    }
  ) {
    final overwrittenLookup =
      UserData.overwrittenLookup(genotypeKey, drug: drug);
    if (useOverwrite && overwrittenLookup != null) {
      return overwrittenLookup.value;
    }
    return UserData.instance.genotypeResults?[genotypeKey]?.lookupkey;
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
    Hive.registerAdapter(LabResultAdapter());
    Hive.registerAdapter(GenotypeResultAdapter());
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
