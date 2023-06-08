import 'dart:async';
import 'package:flutter/material.dart';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareReceive extends StatefulWidget {
  @override
  ShareReceiveState createState() => ShareReceiveState();
}

class ShareReceiveState extends State<ShareReceive> {
  StreamSubscription? _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    // For sharing images coming from outside the app while the app is in the
    // memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((fileStream) {
        // ignore: avoid_print
        print('Received stream!');
        // ignore: avoid_print
        print(fileStream);
      }, onError: (err) {
        // ignore: avoid_print
        print('getIntentDataStream error: $err');
      });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((fileStream) {
      // ignore: avoid_print
      print('Received initial data!');
      // ignore: avoid_print
      print(fileStream);
    });

    // For sharing or opening urls/text coming from outside the app while the
    // app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((textStream) {
        // ignore: avoid_print
        print('Received stream!');
        // ignore: avoid_print
        print(textStream);
      }, onError: (err) {
        // ignore: avoid_print
        print('getIntentTextStream error: $err');
      });

    // For sharing or opening urls/text coming from outside the app while the
    // app is closed
    ReceiveSharingIntent.getInitialText().then((textStream) {
      // ignore: avoid_print
      print('Received initial text!');
      // ignore: avoid_print
      print(textStream);
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
