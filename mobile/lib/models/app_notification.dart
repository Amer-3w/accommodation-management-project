class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final bool read;
  final DateTime createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'].toString(),
        title: json['title'] ?? json['data']?['title'] ?? 'Notification',
        body: json['body'] ?? json['data']?['body'] ?? '',
        category: json['category'] ?? json['data']?['category'] ?? 'general',
        read: json['read_at'] != null || json['read'] == true,
        createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      );
}
