import 'package:flutter/material.dart';

/// App-wide color constants following UNAIR Design System
class AppColors {
  // Brand Colors
  static const primary = Color(0xFF003580); // Navy blue UNAIR
  static const accent = Color(0xFFf5a623); // Golden yellow UNAIR
  static const background = Color(0xFFf0f4f8);
  static const surface = Color(0xFFffffff);
  static const textPrimary = Color(0xFF1a1a2e);
  static const textSecondary = Color(0xFF6b7a99);
  static const border = Color(0xFFe8edf5);

  // Status Colors
  static const waitingBg = Color(0xFFfff3e0);
  static const waitingText = Color(0xFFc45000);
  static const processingBg = Color(0xFFede7f6);
  static const processingText = Color(0xFF4527a0);
  static const completedBg = Color(0xFFe8f5e9);
  static const completedText = Color(0xFF1b5e20);

  // Additional UI Colors
  static const errorBg = Color(0xFFffebee);
  static const errorText = Color(0xFFc62828);
  static const infoBg = Color(0xFFe3f2fd);
  static const infoText = Color(0xFF1565c0);

  /// Get status background color based on status string
  static Color getStatusBg(String status) {
    switch (status) {
      case 'Menunggu':
        return waitingBg;
      case 'Diproses':
        return processingBg;
      case 'Selesai':
        return completedBg;
      default:
        return const Color(0xFFf5f5f5);
    }
  }

  /// Get status text color based on status string
  static Color getStatusText(String status) {
    switch (status) {
      case 'Menunggu':
        return waitingText;
      case 'Diproses':
        return processingText;
      case 'Selesai':
        return completedText;
      default:
        return const Color(0xFF757575);
    }
  }

  /// Get status solid color for chips/timeline dots
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return const Color(0xFFf57c00);
      case 'Diproses':
        return const Color(0xFF5e35b1);
      case 'Selesai':
        return const Color(0xFF2e7d32);
      default:
        return Colors.grey;
    }
  }

  /// Get role color based on role string
  static Color getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFd32f2f);
      case 'helpdesk':
        return const Color(0xFF7b1fa2);
      default:
        return primary;
    }
  }

  /// Get role background color (lighter version)
  static Color getRoleBg(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFffebee);
      case 'helpdesk':
        return const Color(0xFFf3e5f5);
      default:
        return const Color(0xFFe3f2fd);
    }
  }
}
