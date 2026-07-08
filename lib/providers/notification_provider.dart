import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../config/supabase_config.dart';
import 'auth_provider.dart';
import 'dart:async';

/// Notification State
class NotificationState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String? errorMessage;

  NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    int? unreadCount,
    String? errorMessage,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get unread notifications
  List<NotificationModel> get unread =>
      notifications.where((n) => !n.isRead).toList();

  /// Get read notifications
  List<NotificationModel> get read =>
      notifications.where((n) => n.isRead).toList();
}

/// Notification StateNotifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this._ref) : super(NotificationState()) {
    _init();
  }

  final Ref _ref;
  AppAuthState? _lastAuthState;
  RealtimeChannel? _channel;

  void _init() {
    _ref.listen<AppAuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated != _lastAuthState?.isAuthenticated ||
          next.user?.id != _lastAuthState?.user?.id) {
        _lastAuthState = next;
        if (next.user != null) {
          fetchNotifications();
          _subscribeToNotifications();
        } else {
          state = NotificationState();
          _unsubscribe();
        }
      }
    });

    final authState = _ref.read(authProvider);
    _lastAuthState = authState;
    if (authState.isAuthenticated) {
      fetchNotifications();
      _subscribeToNotifications();
    }
  }

  /// Subscribe to realtime notifications
  void _subscribeToNotifications() {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user == null) return;

    _unsubscribe(); // Unsubscribe existing first

    _channel = SupabaseConfig.client
        .channel('notifications:${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            // Handle new notification
            final newData = payload as Map<String, dynamic>;
            if (newData['new'] != null) {
              final newNotif = NotificationModel.fromJson(
                newData['new'] as Map<String, dynamic>,
              );

              // Add new notification to list
              final updated = [newNotif, ...state.notifications];
              final unread = updated.where((n) => !n.isRead).length;
              state = state.copyWith(
                notifications: updated,
                unreadCount: unread,
              );
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            // Handle updated notification
            final newData = payload as Map<String, dynamic>;
            if (newData['new'] != null) {
              final updatedNotif = NotificationModel.fromJson(
                newData['new'] as Map<String, dynamic>,
              );

              // Update notification in list
              final updated = state.notifications.map((n) {
                return n.id == updatedNotif.id ? updatedNotif : n;
              }).toList();
              final unread = updated.where((n) => !n.isRead).length;
              state = state.copyWith(
                notifications: updated,
                unreadCount: unread,
              );
            }
          },
        )
        .subscribe();
  }

  /// Unsubscribe from realtime notifications
  void _unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  /// Fetch notifications for current user
  Future<void> fetchNotifications() async {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await SupabaseConfig.client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final notifications =
          (response as List).map((e) => NotificationModel.fromJson(e)).toList();
      final unread = notifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        isLoading: false,
        notifications: notifications,
        unreadCount: unread,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat notifikasi: ${e.toString()}',
      );
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await SupabaseConfig.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      final updated = state.notifications.map((n) {
        return n.id == notificationId
            ? NotificationModel(
                id: n.id,
                userId: n.userId,
                title: n.title,
                message: n.message,
                type: n.type,
                ticketId: n.ticketId,
                isRead: true,
                createdAt: n.createdAt,
              )
            : n;
      }).toList();

      final unread = updated.where((n) => !n.isRead).length;
      state = state.copyWith(
        notifications: updated,
        unreadCount: unread,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal menandai notifikasi: ${e.toString()}');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user == null) return false;

    try {
      await SupabaseConfig.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);

      final updated = state.notifications.map((n) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          message: n.message,
          type: n.type,
          ticketId: n.ticketId,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();

      state = state.copyWith(
        notifications: updated,
        unreadCount: 0,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal menandai semua: ${e.toString()}');
      return false;
    }
  }

  /// Create notification (for internal use)
  Future<bool> createNotification({
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
}

/// Notification Provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});

/// Unread Count Provider
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});
