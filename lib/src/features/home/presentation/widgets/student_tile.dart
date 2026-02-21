import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:grade_vault_offline/src/core/extensions/extensions.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';

class StudentTile extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap, onDelete;
  const StudentTile({
    super.key,
    required this.student,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: KitColors.neutral100,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: StyledText(student.name, fontSize: 16),
      subtitle: StyledText(
        fontSize: 12,
        '${student.age != null && student.age != 0 ? '${student.age} years • ' : ''}${student.gender}',
      ),
      trailing: AppIconButton(
        icon: CupertinoIcons.trash,
        iconSize: 18,
        onTap: onDelete,
        iconColor: KitColors.red500,
      ),
    ).decorated();
  }
}
