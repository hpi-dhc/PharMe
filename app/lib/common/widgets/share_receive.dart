import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

class ShareReceive extends StatefulWidget {
  const ShareReceive({super.key});

  @override
  State<ShareReceive> createState() => _ShareReceiveState();
}

class _ShareReceiveState extends State<ShareReceive> {
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedFile>? list;
  @override
  void initState() {
    super.initState();
    // For sharing images coming from outside the app while the app is in
    // the memory
    _intentDataStreamSubscription = FlutterSharingIntent.instance.getMediaStream()
        .listen((sharedFiles) {
      setState(() {
        list = sharedFiles;
      });
      // ignore: avoid_print
      print(
        "Shared: getMediaStream ${sharedFiles.map((f) => f.value).join(",")}");
    }, onError: (err) {
      // ignore: avoid_print
      print('getIntentDataStream error: $err');
    });

    // For sharing images coming from outside the app while the app is closed
    FlutterSharingIntent.instance.getInitialSharing().then((sharedFiles) {
      // ignore: avoid_print
      print(
        "Shared: getInitialMedia ${sharedFiles.map((f) => f.value).join(",")}");
      setState(() {
        list = sharedFiles;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              child: Text('Sharing data: \n${list?.join("\n\n")}\n')),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }
}