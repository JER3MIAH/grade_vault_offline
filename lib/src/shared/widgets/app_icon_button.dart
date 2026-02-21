import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grade_vault_offline/src/shared/shared.dart'
    show KitColors, TapBounce, ContextExtensions;

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? fillColor;
  final VoidCallback? onTap;
  final double iconSize;
  const AppIconButton({
    super.key,
    required this.icon,
    this.iconColor = KitColors.black,
    this.fillColor,
    this.onTap,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return TapBounce(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color:
              fillColor ??
              context.colors.secondaryContainer.withValues(alpha: .2),
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
