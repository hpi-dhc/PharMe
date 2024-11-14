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

  Future<void> _waitForDeepLinkSharePublishUrl() async {
    var waitingForDeepLinkSharePublishUrl = true;
    while (waitingForDeepLinkSharePublishUrl) {
      waitingForDeepLinkSharePublishUrl =
        MetaData.instance.deepLinkSharePublishUrl == null;
      await Future.delayed(Duration(seconds: 1));
    }
  }

  @override
  Future<void> authenticate() async {
    await _waitForDeepLinkSharePublishUrl();
  }
  
  @override
  Future<(List<LabResult>, List<String>)> loadData() async {
    publishUrl = Uri.parse(
      MetaData.instance.deepLinkSharePublishUrl!,
    );
    publishHeaders = null;
    return fetchData(
      publishUrl,
      headers: publishHeaders,
    );
  }
}