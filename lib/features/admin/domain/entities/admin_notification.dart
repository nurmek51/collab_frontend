/// Admin Notification entity
class AdminNotification {
  final String id;
  final String type; // new_order, help_request
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool read;
  final String priority; // high, medium, low

  const AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.createdAt,
    required this.read,
    required this.priority,
  });

  /// Check if notification is unread
  bool get isUnread => !read;

  /// Check if notification is high priority
  bool get isHighPriority => priority == 'high';

  /// Get order information if this is a new order notification
  Map<String, dynamic>? get orderData {
    if (type == 'new_order') {
      return data;
    }
    return null;
  }

  /// Get client information from notification data
  String? get clientName {
    final orderData = this.orderData;
    if (orderData != null) {
      final firstName = orderData['client_name'] as String?;
      final lastName = orderData['client_surname'] as String?;
      if (firstName != null && lastName != null) {
        return '$firstName $lastName';
      }
    }
    return null;
  }

  /// Get client phone from notification data
  String? get clientPhone {
    return orderData?['client_phone'] as String?;
  }

  /// Get company name from notification data
  String? get companyName {
    return orderData?['company_name'] as String?;
  }

  /// Get specializations from notification data
  List<String>? get specializations {
    final orderData = this.orderData;
    if (orderData != null && orderData['specializations'] != null) {
      return (orderData['specializations'] as List<dynamic>).cast<String>();
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AdminNotification(id: $id, type: $type, title: $title, read: $read)';
  }
}
