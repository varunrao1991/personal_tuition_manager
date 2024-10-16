import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes/navigator.dart';
import '../providers/notification_provider.dart';

class NotificationHandlerWidget extends StatelessWidget {
  const NotificationHandlerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
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
                right: 11, // Aligns with the right edge of the icon
                top: 11, // Aligns with the top edge of the icon
                child: Container(
                  width: 10, // Size of the badge
                  height: 10, // Size of the badge
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
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
