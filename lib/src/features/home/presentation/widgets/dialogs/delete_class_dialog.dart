import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class DeleteItemDialog extends StatelessWidget {
  final String type;
  final VoidCallback onDelete;
  const DeleteItemDialog({
    super.key,
    required this.type,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DialogActionColumn(
      title: 'Delete Class',
      primaryButtonTitle: 'Delete',
      primaryButtonColor: AppColors.red500,
      onTap: onDelete,
      children: [
        StyledText(
          'Are you sure you want to delete this $type? This cannot be undone.',
        ),
        const YGap(20),
      ],
    );
  }
}
