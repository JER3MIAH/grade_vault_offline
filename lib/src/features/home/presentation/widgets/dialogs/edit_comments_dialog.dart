import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class EditCommentsDialog extends HookConsumerWidget {
  final String studentId;
  final String termName;
  final Comments? comments;

  const EditCommentsDialog({
    super.key,
    required this.studentId,
    required this.termName,
    this.comments,
  });

  @override
  Widget build(BuildContext context, ref) {
    final notifier = ref.read(appStateProvider.notifier);
    final principalCommentController = useTextEditingController(
      text: comments?.principalComment ?? '',
    );
    final teacherCommentController = useTextEditingController(
      text: comments?.teacherComment ?? '',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StyledText(
            'Edit Comments',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),

          const YGap(16),

          /// TEACHER COMMENT
          OutlinedTextField(
            controller: teacherCommentController,
            labelText: 'Teacher\'s comment',
            hintText: 'Enter teacher\'s comment',
          ),

          const YGap(12),

          /// PRINCIPAL COMMENT
          OutlinedTextField(
            controller: principalCommentController,
            labelText: 'Principal\'s comment',
            hintText: 'Enter principal\'s comment',
          ),
          const YGap(16),
          const StyledText(
            'Leave fields empty and the app will generate comments based on the student\'s results',
            fontStyle: FontStyle.italic,
          ),

          const YGap(24),

          /// SUBMIT BUTTON
          PrimaryButton(
            expanded: true,
            title: 'Save',
            onTap: () async {
              await notifier.updateStudentComments(
                studentId: studentId,
                termName: termName,
                teacherComment: teacherCommentController.text.trim(),
                principalComment: principalCommentController.text.trim(),
              );
              if (context.mounted) {
                context.pop();
                context.showSuccessSnackBar('Comments updated successfully');
              }
            },
          ),
        ],
      ),
    );
  }
}
