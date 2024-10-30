import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../routes/navigator.dart';

class NotificationHandlerWidget extends StatelessWidget {
  const NotificationHandlerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, notificationProvider, child) {
        if (notificationProvider.onMessageOpenedStatus) {
          if (ModalRoute.of(context)?.settings.name != '/notification') {
            navigatorKey.currentState?.pushNamed('/notification');
          }
        }

        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                navigatorKey.currentState?.pushNamed('/notification');
              },
            ),
            if (notificationProvider.newNotification)
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
