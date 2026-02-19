import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grade_vault_offline/src/core/navigation/app_routes.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/features/home/presentation/widgets/widgets.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class ClassView extends ConsumerWidget {
  const ClassView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final classSection = appState.currentClass;

    if (classSection == null) {
      return const PageNotFound();
    }
    final String title = classSection.name;
    final String teacherName = classSection.teacherName;
    final students = appState.studentRecords
        .where((record) => record.classId == classSection.id)
        .toList();
    return Scaffold(
      appBar: CustomAppBar(title: title, subtitle: 'Teacher: $teacherName'),
      body: AppColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PrimaryButton(
                title: 'Add Student',
                icon: Icons.add,
                onTap: () {
                  context.showDialog(
                    AddStudentDialog(classId: classSection.id),
                  );
                },
              ),
              PrimaryButton(
                title: 'Add Subject',
                color: AppColors.green500,
                icon: Icons.add,
                onTap: () async {
                  final subjects = await context.showDialog<List<String>>(
                    AddSubjectDialog(
                      existingSubjects: classSection.subjectNames,
                    ),
                  );
                  if (subjects == null) return;

                  notifier.setSubjectsForClass(
                    classId: classSection.id,
                    subjectNames: subjects,
                  );
                },
              ),

              PrimaryButton(
                title: 'BroadSheet',
                color: const Color(0xFF62109F),
                icon: Icons.table_chart,
                onTap: () {
                  context.pushNamed(AppRoutes.broadSheet);
                },
              ),
              PrimaryButton(
                title: 'Settings',
                color: const Color(0xFF1B3C53),
                icon: Icons.settings_outlined,
                onTap: () {
                  context.showDialog(
                    ClassSettingsDialog(classSection: classSection),
                  );
                },
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: ItemCard(
                  title: 'Students',
                  itemCount: students.length,
                  icon: CupertinoIcons.person_2,
                ),
              ),
              Expanded(
                child: ItemCard(
                  title: 'Subjects',
                  itemCount: classSection.subjectNames.length,
                  icon: CupertinoIcons.book,
                  color: AppColors.green500,
                ),
              ),
            ],
          ),
          _StudentsAndSubjectsView(
            studentRecords: students,
            subjectNames: classSection.subjectNames,
            classId: classSection.id,
          ),
        ],
      ),
      floatingActionButton: PrimaryButton(
        title: 'Generate Result',
        onTap: () {
          context.showDialog(GenerateResultDialog(classId: classSection.id));
        },
      ),
    );
  }
}

class _StudentsAndSubjectsView extends HookWidget {
  final List<StudentRecord> studentRecords;
  final List<String> subjectNames;
  final String classId;
  const _StudentsAndSubjectsView({
    required this.studentRecords,
    required this.subjectNames,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {
    final isStudentsTabSelected = useState(true);
    return BorderedCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTab(
                  title: 'Students',
                  isSelected: isStudentsTabSelected.value,
                  onTap: () {
                    isStudentsTabSelected.value = true;
                  },
                ),
              ),
              Expanded(
                child: CustomTab(
                  title: 'Subjects',
                  isSelected: !isStudentsTabSelected.value,
                  onTap: () {
                    isStudentsTabSelected.value = false;
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: isStudentsTabSelected.value
                ? _StudentList(studentRecords: studentRecords)
                : _SubjectList(subjectNames: subjectNames, classId: classId),
          ),
        ],
      ),
    );
  }
}

class _StudentList extends ConsumerWidget {
  final List<StudentRecord> studentRecords;

  const _StudentList({required this.studentRecords});

  @override
  Widget build(BuildContext context, ref) {
    final notifier = ref.read(appStateProvider.notifier);
    if (studentRecords.isEmpty) {
      return const EmptyStateWidget(isStudentTab: true);
    }
    return AnimatedColumn(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: List.generate(studentRecords.length, (index) {
        final student = studentRecords[index];
        return StudentTile(
          student: student.student,
          onTap: () {
            notifier.selectStudent(student.student.id);
            context.pushNamed(AppRoutes.student);
          },
          onDelete: () {
            context.showDialog(
              DeleteItemDialog(
                type: 'student',
                onDelete: () {
                  context.pop();
                  notifier.deleteStudent(student.student.id);
                },
              ),
            );
          },
        );
      }),
    );
  }
}

class _SubjectList extends ConsumerWidget {
  final List<String> subjectNames;
  final String classId;
  const _SubjectList({required this.subjectNames, required this.classId});

  @override
  Widget build(BuildContext context, ref) {
    final notifier = ref.read(appStateProvider.notifier);

    if (subjectNames.isEmpty) {
      return const EmptyStateWidget(isStudentTab: false);
    }
    return AnimatedColumn(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: List.generate(subjectNames.length, (index) {
        final subjectName = subjectNames[index];
        return SubjectTile(
          subjectName: subjectName,
          onDelete: () {
            notifier.deleteSubjectFromClass(
              classId: classId,
              subjectName: subjectName,
            );
          },
        );
      }),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final bool isStudentTab;
  const EmptyStateWidget({super.key, required this.isStudentTab});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isStudentTab ? CupertinoIcons.person_2 : CupertinoIcons.book,
            size: 44,
            color: AppColors.neutral400,
          ),
          StyledText(
            'No ${isStudentTab ? 'students' : 'classes'} Yet',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          StyledText(
            'Get started by creating your first ${isStudentTab ? 'student' : 'class'}',
            fontSize: 12,
            color: AppColors.neutral600,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
