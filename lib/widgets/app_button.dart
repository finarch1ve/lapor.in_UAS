import 'package:flutter/material.dart';

/// Primary Button following UNAIR Design System
/// 10px border radius, background theme primary, white text
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isDanger;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
    this.isDanger = false,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final surface = theme.cardColor;
    final textSecondary = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final border = theme.dividerColor;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isDanger
          ? const Color(0xFFd32f2f)
          : isSecondary
              ? surface
              : primary,
      foregroundColor: isSecondary ? primary : Colors.white,
      disabledBackgroundColor: isSecondary
          ? border
          : textSecondary.withValues(alpha: 0.3),
      disabledForegroundColor: textSecondary.withValues(alpha: 0.5),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isSecondary
            ? BorderSide(color: primary, width: 1.5)
            : const BorderSide(color: Colors.transparent),
      ),
      elevation: isSecondary ? 0 : 2,
    );

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height ?? 48,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    return ElevatedButton(
      style: buttonStyle,
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Full width primary button
class AppButtonFull extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isSecondary;
  final bool isDanger;

  const AppButtonFull({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isSecondary = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
        icon: icon,
        isSecondary: isSecondary,
        isDanger: isDanger,
      ),
    );
  }
}

/// Icon-only circular button (e.g., for FAB)
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: backgroundColor ?? theme.primaryColor,
      borderRadius: BorderRadius.circular(size ?? 56),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size ?? 56),
        child: SizedBox(
          width: size ?? 56,
          height: size ?? 56,
          child: Tooltip(
            message: tooltip ?? '',
            child: Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: (size ?? 56) * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

/// Text button with custom styling
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isBold;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? Theme.of(context).primaryColor,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

/// Action button for ticket operations (Assign, Status, Delete)
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final ActionButtonType type;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.type = ActionButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor = Colors.white;

    switch (type) {
      case ActionButtonType.primary:
        bgColor = Theme.of(context).primaryColor;
        break;
      case ActionButtonType.secondary:
        bgColor = const Color(0xFF7b1fa2);
        break;
      case ActionButtonType.danger:
        bgColor = const Color(0xFFd32f2f);
        break;
      case ActionButtonType.success:
        bgColor = const Color(0xFF2e7d32);
        break;
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

enum ActionButtonType {
  primary,
  secondary,
  danger,
  success,
}