import '../config/supabase_config.dart';
import '../models/notification_model.dart';

/// Notification Service
class NotificationService {
  /// Create notification for user
  static Future<bool> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? ticketId,
  }) async {
    try {
      final notificationData = {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        if (ticketId != null) 'ticket_id': ticketId,
        'is_read': false,
      };

      await SupabaseConfig.client.from('notifications').insert(notificationData);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Notify ticket status change
  static Future<bool> notifyTicketStatusChange({
    required String ticketId,
    required String ticketTitle,
    required String userId,
    required String newStatus,
  }) async {
    return await createNotification(
      userId: userId,
      title: 'Status Tiket Diperbarui',
      message: 'Tiket "$ticketTitle" sekarang berstatus "$newStatus"',
      type: 'status',
      ticketId: ticketId,
    );
  }

  /// Notify new comment
  static Future<bool> notifyNewComment({
    required String ticketId,
    required String ticketTitle,
    required String userId,
    required String commenterName,
  }) async {
    return await createNotification(
      userId: userId,
      title: 'Komentar Baru',
      message: '$commenterName mengomentari tiket "$ticketTitle"',
      type: 'comment',
      ticketId: ticketId,
    );
  }

  /// Notify ticket assignment
  static Future<bool> notifyTicketAssignment({
    required String ticketId,
    required String ticketTitle,
    required String helpdeskId,
  }) async {
    return await createNotification(
      userId: helpdeskId,
      title: 'Tiket Baru Ditugaskan',
      message: 'Tiket "$ticketTitle" telah ditugaskan ke kamu',
      type: 'assign',
      ticketId: ticketId,
    );
  }
}
