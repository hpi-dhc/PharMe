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
  bool cancelPreparationInApp= true;

  @override
  String? preparationLoadingMessage() =>
    'Please open the $shareAppName and share your data with PharMe';

  Future<void> _waitForDeepLinkSharePublishUrl() async {
    var waitingForDeepLinkSharePublishUrl = true;
    while (waitingForDeepLinkSharePublishUrl) {
      waitingForDeepLinkSharePublishUrl =
        MetaData.instance.deepLinkSharePublishUrl == null;
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<void> _setAwaitingDeepLinkSharePublishUrl(bool newValue) async {
    MetaData.instance.awaitingDeepLinkSharePublishUrl = newValue;
    await MetaData.save();
  }

  @override
  Future<void> prepareDataLoad() async {
    await _setAwaitingDeepLinkSharePublishUrl(true);
    await _waitForDeepLinkSharePublishUrl();
  }
  
  @override
  Future<(List<LabResult>, List<String>)> loadData() async {
    await _setAwaitingDeepLinkSharePublishUrl(false);
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