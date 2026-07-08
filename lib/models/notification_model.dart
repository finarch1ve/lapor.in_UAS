/// Notification Model
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'status', 'comment', 'assign'
  final String? ticketId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.ticketId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      ticketId: json['ticket_id'] as String?,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'ticket_id': ticketId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Get icon based on type
  String get iconName {
    switch (type) {
      case 'status':
        return 'sync';
      case 'comment':
        return 'comment';
      case 'assign':
        return 'person_pin';
      default:
        return 'notifications';
    }
  }

  // Get color based on type
  String get colorName {
    switch (type) {
      case 'status':
        return 'purple';
      case 'comment':
        return 'blue';
      case 'assign':
        return 'teal';
      default:
        return 'grey';
    }
  }

  // Format time for display
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} jam lalu';
    } else {
      return '${diff.inDays} hari lalu';
    }
  }
}
