import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int itemCount;
  final Color color;
  const ItemCard({
    super.key,
    required this.title,
    required this.icon,
    required this.itemCount,
    this.color = AppColors.blue500,
  });

  @override
  Widget build(BuildContext context) {
    return BorderedCard(
      child: Row(
        spacing: 12,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StyledText(title, fontSize: 14, fontWeight: FontWeight.w400),
              const XGap(4),
              StyledText(
                '$itemCount',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
