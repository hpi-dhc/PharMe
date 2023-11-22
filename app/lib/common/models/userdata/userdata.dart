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
    this.overwrittenPhenotype,
  });

  String phenotype;
  String? adaptionText;
  String? overwrittenPhenotype;
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
  Map<String, Diplotype>? diplotypes;

  static PhenotypeInformation phenotypeFor(
    String gene,
    BuildContext context,
    {
      String? drug,
      String userSalutation = 'you',
    }
  ) {
    final originalPhenotype = UserData.instance.diplotypes?[gene]?.phenotype;
    if (originalPhenotype == null) {
      return PhenotypeInformation(
        phenotype: context.l10n.general_not_tested,
      );
    }
    final activeInhibitors = UserData.activeInhibitorsFor(gene, drug: drug);
    if (activeInhibitors.isEmpty) {
      return PhenotypeInformation(phenotype: originalPhenotype);
    }
    final overwrittenLookup = UserData.overwrittenLookup(gene, drug: drug);
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
    final activeStrongInhibitors = activeInhibitors.filter(
      isStrongInhibitor
    ).toList();
    final activeModerateInhibitors = activeInhibitors.filter(
      isModerateInhibitor
    ).toList();
    final overwritePhenotype = context.l10n.general_poor_metabolizer;
    final currentPhenotypeEqualsOverwritePhenotype =
      originalPhenotype.toLowerCase() == overwritePhenotype.toLowerCase();
    if (currentPhenotypeEqualsOverwritePhenotype) {
      return PhenotypeInformation(
        phenotype: originalPhenotype,
        adaptionText: context.l10n.drugs_page_inhibitors_poor_metabolizer(
          userSalutation,
          enumerationWithAnd(
            activeInhibitors,
            context
          ),
        ),
      );
    }
    final adaptionText = activeModerateInhibitors.isEmpty
      ? context.l10n.drugs_page_strong_inhibitors(
          userSalutation,
          enumerationWithAnd(activeStrongInhibitors, context),
        )
      : context.l10n.drugs_page_moderate_and_strong_inhibitors(
          userSalutation,
          enumerationWithAnd(activeStrongInhibitors, context),
          enumerationWithAnd(activeModerateInhibitors, context),
        );
    return PhenotypeInformation(
      phenotype: overwritePhenotype,
      adaptionText: adaptionText,
      overwrittenPhenotype: originalPhenotype,
    );
  }

  static String? genotypeFor(String gene) =>
      UserData.instance.diplotypes?[gene]?.genotype;

  static String? allelesTestedFor(String gene) =>
      UserData.instance.diplotypes?[gene]?.allelesTested;

  @HiveField(1)
  Map<String, CpicPhenotype>? lookups;

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
    String gene,
    {
      String? drug,
      bool useOverwrite = true,
    }
  ) {
    final overwrittenLookup = UserData.overwrittenLookup(gene, drug: drug);
    if (useOverwrite && overwrittenLookup != null) {
      return overwrittenLookup.value;
    }
    return UserData.instance.lookups?[gene]?.lookupkey;
  }

  // hive can't deal with sets so we have to use a list :(
  @HiveField(2)
  List<String>? activeDrugNames;

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

class ActiveDrugs extends ChangeNotifier {
  List<String> names = [];

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
}

/// Initializes the user's data by registering all necessary adapters and
/// loading pre-existing data from local storage, if it exists.
Future<void> initUserData() async {
  // We only want to register the necessary adapters once. If it has already been
  // registered, we return early as to avoid overwriting changed data from the
  // session which has not yet been written to local storage.
  try {
    Hive.registerAdapter(UserDataAdapter());
    Hive.registerAdapter(DiplotypeAdapter());
    Hive.registerAdapter(CpicPhenotypeAdapter());
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
