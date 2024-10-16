import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_deletable_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late ScrollController _scrollController;
  bool _isSelectMode = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNotifications();
    });
  }

  Future<void> _fetchNotifications() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    try {
      await notificationProvider.fetchNotifications();
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    try {
      await notificationProvider.deleteNotification(notificationId);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_isSelectMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Handle batch delete logic if needed
                _toggleSelectMode();
              },
            )
        ],
      ),
      body: _buildNotificationList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSelectMode,
        child: Icon(_isSelectMode ? Icons.check : Icons.select_all),
      ),
    );
  }

  Widget _buildNotificationList() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (notificationProvider.isLoading &&
            notificationProvider.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: RefreshIndicator(
            onRefresh: _fetchNotifications,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return CustomDeletableCard(
                  child: ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.body),
                    tileColor:
                        notification.isRead ? Colors.grey[200] : Colors.white,
                    onTap: () {
                      if (!_isSelectMode) {
                        // Mark as read logic here
                        _markAsRead(notification.id);
                      }
                    },
                  ),
                  onDelete: () async {
                    bool? success =
                        await _showDeleteConfirmationDialog(context);
                    if (success == true) {
                      _deleteNotification(notification.id);
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _markAsRead(int notificationId) async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    try {
      await notificationProvider.markNotificationAsRead(notificationId);
      setState(() {}); // Refresh the UI
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content:
              const Text('Are you sure you want to delete this notification?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
