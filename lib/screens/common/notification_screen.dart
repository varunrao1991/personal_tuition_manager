import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final ScrollController _scrollController;
  bool _showUnreadOnly = true;
  final Set<String> _selectedNotifications = {};
  String? _expandedNotificationId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchNotifications();
      _resetNewNotifications();
    });
  }

  void _resetNewNotifications() {
    Provider.of<AuthProvider>(context, listen: false).resetNotification();
  }

  Future<void> _fetchNotifications() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    try {
      await notificationProvider.fetchNotifications(unread: _showUnreadOnly);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  void _toggleSelectAllNotifications() {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    setState(() {
      if (_selectedNotifications.length ==
          notificationProvider.notifications.length) {
        _selectedNotifications.clear();
      } else {
        _selectedNotifications.addAll(
          notificationProvider.notifications.map((notif) => notif.messageId),
        );
      }
    });
  }

  Future<void> _markSelectedAsRead() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    try {
      await notificationProvider
          .markNotificationAsRead(_selectedNotifications.toList());
      _selectedNotifications.clear();
      setState(() {});
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _deleteSelectedNotifications(
      List<String> notificationIds) async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    try {
      await notificationProvider.deleteNotifications(notificationIds);
      _selectedNotifications.clear();
      setState(() {});
    } catch (e) {
      handleErrors(context, e);
    }
  }

  bool get _isAnySelected => _selectedNotifications.isNotEmpty;

  bool get _isAnyUnreadSelected {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    return _selectedNotifications.any((id) {
      final notification = notificationProvider.notifications
          .firstWhere((notif) => notif.messageId == id);
      return notification.status != 'read';
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
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isAnySelected
                ? () => _deleteSelectedNotifications(
                    _selectedNotifications.toList())
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _isAnyUnreadSelected ? _markSelectedAsRead : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _toggleSelectAllNotifications,
                  child: const Text('Select All'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedNotifications.clear();
                  }),
                  child: const Text('Deselect All'),
                ),
                Row(
                  children: [
                    const Text('Unread'),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: _showUnreadOnly,
                        onChanged: (value) async {
                          setState(() {
                            _showUnreadOnly = value;
                          });
                          await _fetchNotifications();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _buildNotificationList()),
        ],
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

        if (notificationProvider.notifications.isEmpty) {
          return Center(
            child: Text(
              'No notifications to show.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchNotifications,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              final isSelected =
                  _selectedNotifications.contains(notification.messageId);
              final isExpanded =
                  _expandedNotificationId == notification.messageId;

              bool isRead = notification.status == 'read';
              return CustomCard(
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _expandedNotificationId =
                        isExpanded ? null : notification.messageId;
                  });
                },
                child: Stack(
                  children: [
                    ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            DateFormat('EEE, dd MMM y')
                                .format(notification.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            notification.body,
                            maxLines: isExpanded ? null : 2,
                            overflow: isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: -2.0,
                      top: -2.0,
                      child: isRead
                          ? const Icon(
                              Icons.done_all,
                              color: Colors.green,
                              size: 20,
                            )
                          : Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedNotifications
                                        .add(notification.messageId);
                                  } else {
                                    _selectedNotifications
                                        .remove(notification.messageId);
                                  }
                                });
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
