import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  if (message.data['route'] != null) {
    String route = message.data['route'];
    log('Background message received: ${message.messageId}, navigating to: $route');
  }
}
