import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class SubjectListTile extends StatelessWidget {
  final String subject;
  final VoidCallback? onTap;

  const SubjectListTile({super.key, required this.subject, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(onTap: onTap, title: StyledText(subject));
  }
}
