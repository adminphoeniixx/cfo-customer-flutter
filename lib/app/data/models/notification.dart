import '../../core/utils/json_utils.dart';

class AppNotification {
  final int id;
  final String? title;
  final String? body;
  final String? type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    this.title,
    this.body,
    this.type,
    this.data,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: asInt(j['id']),
        title: j['title'],
        body: j['body'] ?? j['message'],
        type: j['type'],
        data: j['data'] == null ? null : Map<String, dynamic>.from(j['data']),
        isRead: asBool(j['is_read'] ?? (j['read_at'] != null)),
        createdAt: j['created_at'] == null ? null : DateTime.tryParse(j['created_at']),
      );
}
