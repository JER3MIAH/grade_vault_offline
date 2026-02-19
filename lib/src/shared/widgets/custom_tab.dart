import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class CustomTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;
  const CustomTab({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.1)
              : null,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? context.colors.primary : AppColors.neutral300,
              width: isSelected ? 2 : .5,
            ),
          ),
        ),
        duration: const Duration(milliseconds: 300),
        child: Center(
          child: StyledText(
            title,
            color: isSelected ? context.colors.primary : null,
          ),
        ),
      ),
    );
  }
}
