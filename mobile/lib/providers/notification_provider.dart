import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider.empty();

  NotificationService? _service;
  List<AppNotification> notifications = [];
  bool loading = false;

  int get unreadCount => notifications.where((item) => !item.read).length;

  void attach(NotificationService service) => _service = service;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      notifications = await _service!.list();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    await _service!.markAllRead();
    notifications = notifications
        .map((item) => AppNotification(
              id: item.id,
              title: item.title,
              body: item.body,
              category: item.category,
              read: true,
              createdAt: item.createdAt,
            ))
        .toList();
    notifyListeners();
  }
}
