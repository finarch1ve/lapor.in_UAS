import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Status Badge Widget (Pill-shaped chip)
/// Displays ticket status with appropriate colors
class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsets? padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getStatusBg(status),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getStatusText(status).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: AppColors.getStatusText(status),
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Compact status badge for inline use
class CompactStatusBadge extends StatelessWidget {
  final String status;

  const CompactStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.getStatusBg(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Role Badge Widget (Pill-shaped)
/// Displays user role with appropriate colors
class RoleBadge extends StatelessWidget {
  final String role;
  final double? fontSize;

  const RoleBadge({
    super.key,
    required this.role,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getRoleBg(role),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getRoleColor(role).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: AppColors.getRoleColor(role),
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
