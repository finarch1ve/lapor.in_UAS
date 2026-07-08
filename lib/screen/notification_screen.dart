import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_uts/providers/notification_provider.dart';
import 'package:ticketing_uts/widgets/app_card.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;
    final unreadCount = notificationState.unreadCount;
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodySmall?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifikasi'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
              child: const Text(
                'Tandai Semua Dibaca',
                style: TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const EmptyStateCard(
                  message: 'Tidak ada notifikasi',
                  icon: Icons.notifications_none,
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(notificationProvider.notifier).fetchNotifications(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final n = notifications[i];
                      final isRead = n.isRead;

                      return AppCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () async {
                          await ref.read(notificationProvider.notifier).markAsRead(n.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Membuka ${n.title}')),
                            );
                          }
                        },
                        backgroundColor: !isRead
                            ? primary.withValues(alpha: 0.08)
                            : null,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon container
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _getNotificationColor(n.type, primary).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getNotificationIcon(n.type),
                                color: _getNotificationColor(n.type, primary),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: !isRead ? FontWeight.w600 : FontWeight.w500,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (!isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    n.message,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n.formattedTime,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'status':
        return Icons.sync;
      case 'comment':
        return Icons.comment;
      case 'assign':
        return Icons.person_pin;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type, Color primary) {
    switch (type) {
      case 'status':
        return const Color(0xFF7b1fa2);
      case 'comment':
        return primary;
      case 'assign':
        return const Color(0xFF00897b);
      default:
        return Colors.grey;
    }
  }
}