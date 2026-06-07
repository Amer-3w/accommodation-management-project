import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';
import '../core/utils/json_parsers.dart';

class NotificationService {
  NotificationService(this._repository);

  final NotificationRepository _repository;

  Future<List<AppNotification>> list() async {
    final json = await _repository.list();
    return asListData(json).whereType<Map<String, dynamic>>().map(AppNotification.fromJson).toList();
  }

  Future<void> markAllRead() async {
    await _repository.markAllRead();
  }
}
