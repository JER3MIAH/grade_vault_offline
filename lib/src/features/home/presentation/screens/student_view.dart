import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/features/home/presentation/widgets/student_result_preview.dart';
import 'package:grade_vault_offline/src/features/home/presentation/widgets/widgets.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class StudentView extends HookConsumerWidget {
  const StudentView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final classSection = appState.currentClass;
    final studentRecord = appState.currentStudent;
    final selectedTerm = useState<String>(appState.currentTerm);

    if (studentRecord == null || classSection == null) {
      return const PageNotFound();
    }
    return Scaffold(
      appBar: const CustomAppBar(title: 'Student Details'),
      body: KitColumn(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StudentCard(
            classId: classSection.id,
            student: studentRecord.student,
          ),
          Row(
            spacing: 8,
            children: [
              SizedBox(
                width: 150,
                child: KitSelector(
                  items: TERM_LIST,
                  borderColor: KitColors.neutral200,
                  focusedBorderColor: KitColors.neutral200,
                  hintText: 'Select Term',
                  value: selectedTerm.value,
                  onChanged: (val) {
                    if (val == null) return;
                    selectedTerm.value = val;
                    notifier.setCurrentTerm(val);
                  },
                ),
              ),
              const Spacer(),
              PrimaryButton(
                title: 'Edit Scores',
                icon: Icons.edit_outlined,
                iconOnly: context.isMobile,
                onTap: () {
                  final termResult = studentRecord.getTermResult(
                    selectedTerm.value,
                  );
                  if (termResult == null) {
                    context.showErrorSnackBar(
                      'No scores found for ${selectedTerm.value}',
                    );
                    return;
                  }
                  context.showDialog(
                    EditScoresDialog(
                      studentId: studentRecord.student.id,
                      termName: selectedTerm.value,
                      termResult: termResult,
                    ),
                  );
                },
              ),
              PrimaryButton(
                title: 'Edit Comments',
                color: KitColors.green500,
                icon: CupertinoIcons.bubble_left_bubble_right,
                iconOnly: context.isMobile,
                onTap: () {
                  final termResult = studentRecord.getTermResult(
                    selectedTerm.value,
                  );
                  context.showDialog(
                    EditCommentsDialog(
                      studentId: studentRecord.student.id,
                      termName: selectedTerm.value,
                      comments: termResult != null
                          ? Comments(
                              teacherComment: termResult.teacherComment,
                              principalComment: termResult.principalComment,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
          StudentResultPreview(
            appState: appState,
            classId: classSection.id,
            studentId: studentRecord.student.id,
            termName: selectedTerm.value,
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String classId;
  final Student student;
  const _StudentCard({required this.classId, required this.student});

  @override
  Widget build(BuildContext context) {
    return BorderedCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              StyledText(
                student.name,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              StyledText(
                '${student.age != null && student.age != 0 ? 'Age: ${student.age} years ' : ''}Gender: ${student.gender}',
                fontSize: 14,
              ),
            ],
          ),
          AppIconButton(
            icon: CupertinoIcons.pencil_outline,
            iconColor: context.colors.primary,
            onTap: () {
              context.showDialog(
                AddStudentDialog(classId: classId, student: student),
              );
            },
          ),
        ],
      ),
    );
  }
}
