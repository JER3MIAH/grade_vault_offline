import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:grade_vault_offline/src/core/extensions/extensions.dart';

class SubjectTile extends StatelessWidget {
  final String subjectName;
  final VoidCallback? onDelete;
  const SubjectTile({super.key, required this.subjectName, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.neutral100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: StyledText(subjectName, fontSize: 16),
      trailing: AppIconButton(
        icon: CupertinoIcons.trash,
        iconSize: 18,
        onTap: onDelete,
        iconColor: AppColors.red500,
      ),
    ).decorated();
  }
}
