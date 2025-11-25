import '../../domain/entities/admin_notification.dart';

/// Admin Notification model for data layer
class AdminNotificationModel extends AdminNotification {
  const AdminNotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    required super.data,
    required super.createdAt,
    required super.read,
    required super.priority,
  });

  /// Create AdminNotificationModel from JSON
  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) {
    return AdminNotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : {},
      createdAt: DateTime.parse(json['created_at'] as String),
      read: json['read'] as bool,
      priority: json['priority'] as String,
    );
  }

  /// Convert AdminNotificationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'read': read,
      'priority': priority,
    };
  }

  /// Create AdminNotificationModel from AdminNotification entity
  factory AdminNotificationModel.fromEntity(AdminNotification notification) {
    return AdminNotificationModel(
      id: notification.id,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      data: notification.data,
      createdAt: notification.createdAt,
      read: notification.read,
      priority: notification.priority,
    );
  }
}

/// Model for admin notifications response
class AdminNotificationsResponse {
  final List<AdminNotificationModel> notifications;
  final int totalCount;
  final int unreadCount;

  const AdminNotificationsResponse({
    required this.notifications,
    required this.totalCount,
    required this.unreadCount,
  });

  factory AdminNotificationsResponse.fromJson(Map<String, dynamic> json) {
    return AdminNotificationsResponse(
      notifications: (json['notifications'] as List<dynamic>)
          .map(
            (notif) =>
                AdminNotificationModel.fromJson(notif as Map<String, dynamic>),
          )
          .toList(),
      totalCount: json['total_count'] as int,
      unreadCount: json['unread_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.map((notif) => notif.toJson()).toList(),
      'total_count': totalCount,
      'unread_count': unreadCount,
    };
  }
}
