import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'status_badge.dart';

/// Styled Card Container following UNAIR Design System
/// 12px border radius, 1px border, background follows theme
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BoxBorder? border;
  final bool elevated;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.border,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: border ??
            Border.all(
              color: theme.dividerColor,
              width: 1,
            ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Ticket Card with status indicator on the left
class TicketCard extends StatelessWidget {
  final String title;
  final String ticketId;
  final String category;
  final String date;
  final String status;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showStatusDot;

  const TicketCard({
    super.key,
    required this.title,
    required this.ticketId,
    required this.category,
    required this.date,
    required this.status,
    this.onTap,
    this.trailing,
    this.showStatusDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodySmall?.color;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          // Status indicator dot (left side)
          if (showStatusDot)
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.getStatusColor(status),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Subtitle: ID + Category + Date
                  Row(
                    children: [
                      Text(
                        ticketId,
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                      Text(' • ', style: TextStyle(color: textSecondary)),
                      Text(
                        category,
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                      Text(' • ', style: TextStyle(color: textSecondary)),
                      Text(
                        date,
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Trailing widget or status badge
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: trailing ?? StatusBadge(status: status),
          ),
        ],
      ),
    );
  }
}

/// Hero Card for dashboard greeting
class HeroCard extends StatelessWidget {
  final String userName;
  final String role;
  final int activeTicketCount;
  final VoidCallback? onTap;

  const HeroCard({
    super.key,
    required this.userName,
    required this.role,
    required this.activeTicketCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, const Color(0xFF0047a8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, $userName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RoleBadge(
                    role: role,
                    fontSize: 10,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$activeTicketCount',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Tiket Aktif',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat Card for dashboard statistics
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
          ],
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Empty State Card
class EmptyStateCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? subtitle;

  const EmptyStateCard({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}