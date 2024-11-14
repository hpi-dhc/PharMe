import '../../common/module.dart';
import 'lab.dart';

class DeepLinkShareFlowLab extends Lab {
  DeepLinkShareFlowLab({
    required super.name,
    required this.shareAppName,
  });

  String shareAppName;
  late Uri publishUrl;
  late Map<String, String>? publishHeaders;

  @override
  // ignore: overridden_fields
  bool cancelAuthInApp = true;

  @override
  String? authLoadingMessage() =>
    'Please open the $shareAppName and share your data with PharMe';

  @override
  Future<void> authenticate() async {
    // THIS IS FOR TESTING, SHOULD WAIT UNTIL A DEEP LINK IS RECEIVED
    // (if possible like this but could set metadata field when deep link
    // caught and wait here until it was set)
    await Future.delayed(Duration(seconds: 7));
  }
  
  @override
  Future<(List<LabResult>, List<String>)> loadData() async {
    // THIS IS FOR TESTING, SHOULD GET FROM DWA
    publishUrl = Uri.parse(
      'https://hpi-datastore.duckdns.org/userdata?id=1e006a69-b693-43d2-a318-22904e305b5c',
    );
    publishHeaders = null;
    return fetchData(
      publishUrl,
      headers: publishHeaders,
    );
  }
}