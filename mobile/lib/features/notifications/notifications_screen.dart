import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/EduStay_design.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/EduStay_components.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  static const route = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<NotificationProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
              onPressed: provider.markAllRead,
              child: const Text('Mark all read'))
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemBuilder: (_, index) {
                final item = provider.notifications[index];
                return FadeSlideIn(
                  delay: Duration(milliseconds: index * 35),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color:
                            item.read ? Colors.white : EduStayColors.softOrange,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: EduStayShadows.soft),
                    child: Row(
                      children: [
                        CircleAvatar(
                            backgroundColor: item.read
                                ? EduStayColors.softGreen
                                : EduStayColors.orange,
                            child: Icon(_icon(item.category),
                                color: item.read
                                    ? EduStayColors.darkGreen
                                    : Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(item.body,
                                  style: const TextStyle(
                                      color: EduStayColors.secondaryText,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: provider.notifications.length,
            ),
    );
  }

  IconData _icon(String category) {
    switch (category) {
      case 'booking':
        return Icons.calendar_month_outlined;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'payment':
        return Icons.payments_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
