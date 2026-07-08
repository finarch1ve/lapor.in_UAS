import 'package:flutter/material.dart';
import 'app_colors.dart';

/// UNAIR Logo Widget
/// Displays the UNAIR logo as a circle with navy background,
/// gold ring, "UNAIR" text in white, and "1954" in gold
class UnairLogo extends StatelessWidget {
  final double size;
  final bool showRing;

  const UnairLogo({
    super.key,
    this.size = 60,
    this.showRing = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gold ring (outer circle)
          if (showRing)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent,
                  width: size * 0.03,
                ),
              ),
            ),

          // Navy circle (inner background)
          Container(
            width: size * (showRing ? 0.9 : 1),
            height: size * (showRing ? 0.9 : 1),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),

          // UNAIR text and year
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'UNAIR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: size * 0.01,
                ),
              ),
              SizedBox(height: size * 0.02),
              Text(
                '1954',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Header logo variant with app name next to it
class UnairHeaderLogo extends StatelessWidget {
  final double logoSize;
  final String? appName;

  const UnairHeaderLogo({
    super.key,
    this.logoSize = 40,
    this.appName = 'Helpdesk',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UnairLogo(size: logoSize, showRing: false),
        if (appName != null) ...[
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UNAIR',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: logoSize * 0.32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                appName!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: logoSize * 0.22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
