import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class BorderedCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  const BorderedCard({
    super.key,
    required this.child,
    this.borderColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: KitColors.white,
          border: Border.all(
            color: borderColor ?? KitColors.neutral200,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}
