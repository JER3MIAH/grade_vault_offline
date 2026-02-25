import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class ExportDataDialog extends HookConsumerWidget {
  const ExportDataDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final allClasses = appState.classSections;

    // States
    final selectedClassIds = useState<Set<String>>(
      allClasses.map((c) => c.id).toSet(),
    );
    final exportWithScores = useState<bool>(true);

    final isAllSelected =
        selectedClassIds.value.length == allClasses.length &&
        allClasses.isNotEmpty;

    void toggleAll() {
      if (isAllSelected) {
        selectedClassIds.value = {};
      } else {
        selectedClassIds.value = allClasses.map((c) => c.id).toSet();
      }
    }

    void toggleClass(String id) {
      final current = Set<String>.from(selectedClassIds.value);
      if (current.contains(id)) {
        current.remove(id);
      } else {
        current.add(id);
      }
      selectedClassIds.value = current;
    }

    return DialogActionColumn(
      title: 'Export Data',
      primaryButtonTitle: 'Export ${selectedClassIds.value.length} Classes',
      onTap: selectedClassIds.value.isEmpty
          ? () {}
          : () async {
              final selectedClasses = allClasses
                  .where((c) => selectedClassIds.value.contains(c.id))
                  .toList();

              List<StudentRecord> selectedStudents = appState.studentRecords
                  .where((s) => selectedClassIds.value.contains(s.classId))
                  .toList();

              if (!exportWithScores.value) {
                // Remove score data
                selectedStudents = selectedStudents.map((student) {
                  return student.copyWith(
                    termResults: student.termResults.map((term) {
                      return term.copyWith(
                        teacherComment: '',
                        principalComment: '',
                        subjects: term.subjects.map((sub) {
                          return sub.copyWith(caScore: 0, examScore: 0);
                        }).toList(),
                      );
                    }).toList(),
                  );
                }).toList();
              }

              final service = BackupDataService();
              final filePath = await service.exportData(
                classes: selectedClasses,
                students: selectedStudents,
              );

              if (context.mounted) {
                if (filePath != null) {
                  context.showSuccessSnackBar('Data exported locally');
                } else {
                  context.showErrorSnackBar('Failed to export data');
                }
                context.pop();
              }
            },
      children: [
        const StyledText(
          'Select the classes you want to export. You can also choose whether to include student scores and comments.',
          color: KitColors.neutral600,
          fontSize: 14,
        ),
        const YGap(20),

        // Options
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: KitColors.neutral200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              CheckboxListTile(
                title: const StyledText(
                  'Export with Score Data',
                  fontWeight: FontWeight.w500,
                ),
                subtitle: const StyledText(
                  'If unchecked, all scores will be 0 and comments will be cleared',
                  fontSize: 12,
                  color: KitColors.neutral500,
                ),
                value: exportWithScores.value,
                onChanged: (val) => exportWithScores.value = val ?? true,
                checkColor: KitColors.white,
                activeColor: KitColors.blue500,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
              const Divider(height: 1),
              CheckboxListTile(
                title: const StyledText(
                  'Select All Classes',
                  fontWeight: FontWeight.w500,
                ),
                value: isAllSelected,
                onChanged: (_) => toggleAll(),
                checkColor: KitColors.white,
                activeColor: KitColors.blue500,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ],
          ),
        ),

        const YGap(16),
        const StyledText('Available Classes', fontWeight: FontWeight.w600),
        const YGap(8),

        // Classes List
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            border: Border.all(color: KitColors.neutral200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: allClasses.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: StyledText(
                      'No classes available',
                      color: KitColors.neutral500,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: allClasses.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final classItem = allClasses[index];
                    final isSelected = selectedClassIds.value.contains(
                      classItem.id,
                    );
                    return CheckboxListTile(
                      title: StyledText(
                        classItem.name,
                        fontWeight: FontWeight.w500,
                      ),
                      subtitle: StyledText(
                        '${classItem.session} • ${classItem.branch}',
                        fontSize: 12,
                      ),
                      value: isSelected,
                      onChanged: (_) => toggleClass(classItem.id),
                      checkColor: KitColors.white,
                      activeColor: KitColors.blue500,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
