import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/core/license/license_notifier.dart';
import 'package:grade_vault_offline/src/features/home/presentation/widgets/widgets.dart';
import 'package:grade_vault_offline/src/features/onboarding/license_management_dialog.dart';
import 'package:grade_vault_offline/src/features/settings/presentation/providers/action_tracker_notifier.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class BroadSheetView extends HookConsumerWidget {
  const BroadSheetView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final classSection = appState.currentClass;
    void pop() {
      context.pop();
    }

    if (classSection == null) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'Annual Broad Sheet'),
        body: Center(child: Text('No class selected')),
      );
    }

    // Get all students in this class
    final studentsInClass = appState.studentsInCurrentClass;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Annual Broad Sheet'),
      body: studentsInClass.isEmpty
          ? const Center(child: Text('No students in this class'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: studentsInClass.length,
              itemBuilder: (context, index) {
                final studentRecord = studentsInClass[index];
                return _BroadSheetCard(
                  appState: appState,
                  classSection: classSection,
                  studentRecord: studentRecord,
                );
              },
            ),
      floatingActionButton: studentsInClass.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                final isDemo =
                    ref.read(licenseProvider).name == 'Demo High School';
                if (isDemo) {
                  final actionTracker = ref.read(saveLimitProvider.notifier);
                  final canGenerate = await actionTracker.attemptAction();
                  if (!context.mounted) return;
                  if (!canGenerate) {
                    context.showErrorSnackBar(
                      'Action limit exceeded. Please upgrade your license to generate more results.',
                      SnackBarAction(
                        label: 'Upgrade',
                        onPressed: () {
                          context.showDialog(
                            const LicenseManagementDialog(),
                            maxWidth: 800,
                          );
                        },
                      ),
                    );
                    return;
                  }
                }

                final file = await PdfHelper().generateBroadSheetPdf(
                  appState: appState,
                  classId: classSection.id,
                );
                pop();
                if (!context.mounted) return;
                await const PdfDeliveryService().deliver(
                  context: context,
                  file: file,
                  successMessage: 'Result PDF generated',
                  errorMessage: 'An error occured while generating pdf',
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate PDF'),
            )
          : null,
    );
  }
}

class _BroadSheetCard extends HookWidget {
  final AppState appState;
  final ClassSection classSection;
  final StudentRecord studentRecord;

  const _BroadSheetCard({
    required this.appState,
    required this.classSection,
    required this.studentRecord,
  });

  Widget _cell(String text, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _horizontalLine() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: .5,
      width: double.infinity,
      color: KitColors.neutral200,
    );
  }

  Widget _keyValue(
    String key,
    String value, {
    TextAlign align = TextAlign.center,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        textAlign: align,
        text: TextSpan(
          text: '$key: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalController = useScrollController();

    // Collect term results for all three terms
    final firstTermResult = studentRecord.getTermResult('First Term');
    final secondTermResult = studentRecord.getTermResult('Second Term');
    final thirdTermResult = studentRecord.getTermResult('Third Term');

    // Build a map of subject name -> [term1Total, term2Total, term3Total]
    final Map<String, List<double?>> subjectScores = {};

    // Helper to add subjects from a term
    void addSubjectsFromTerm(TermResult? termResult, int termIndex) {
      if (termResult == null) return;
      for (final subject in termResult.subjects) {
        if (!subjectScores.containsKey(subject.subjectName)) {
          subjectScores[subject.subjectName] = [null, null, null];
        }
        subjectScores[subject.subjectName]![termIndex] = subject.total;
      }
    }

    addSubjectsFromTerm(firstTermResult, 0);
    addSubjectsFromTerm(secondTermResult, 1);
    addSubjectsFromTerm(thirdTermResult, 2);

    // If no subjects at all, show empty message
    if (subjectScores.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        alignment: Alignment.center,
        child: Text(
          'Preview unavailable: No subject data for ${studentRecord.student.name}',
        ),
      );
    }

    // Get all students in this class for subject totals
    final studentsInClass = appState.studentRecords
        .where((s) => s.classId == classSection.id)
        .toList();

    // Build subject average totals map for positions (per subject annual average per student)
    final Map<String, List<double>> subjectAverageTotalsMap = {};
    for (final record in studentsInClass) {
      final firstTerm = record.getTermResult('First Term');
      final secondTerm = record.getTermResult('Second Term');
      final thirdTerm = record.getTermResult('Third Term');

      final Map<String, List<double>> subjToTermTotals = {};
      void collect(term) {
        if (term == null) return;
        for (final s in term.subjects) {
          subjToTermTotals.putIfAbsent(s.subjectName, () => []);
          subjToTermTotals[s.subjectName]!.add(s.total);
        }
      }

      collect(firstTerm);
      collect(secondTerm);
      collect(thirdTerm);

      subjToTermTotals.forEach((name, totals) {
        if (totals.isEmpty) return;
        final avg = totals.reduce((a, b) => a + b) / totals.length;
        subjectAverageTotalsMap.putIfAbsent(name, () => []);
        subjectAverageTotalsMap[name]!.add(avg);
      });
    }

    // Compute subject averages for current student and derive totals/overall average
    double sumOfSubjectAverages = 0;
    int subjectCountForStudent = 0;
    subjectScores.forEach((_, scores) {
      final valid = scores.where((s) => s != null).cast<double>().toList();
      if (valid.isNotEmpty) {
        final avg = valid.reduce((a, b) => a + b) / valid.length;
        sumOfSubjectAverages += avg;
        subjectCountForStudent++;
      }
    });
    final overallAverage = subjectCountForStudent > 0
        ? sumOfSubjectAverages / subjectCountForStudent
        : 0.0;

    // Calculate each student's overall annual average (average of subject annual averages)
    final List<double> allStudentAverages = [];
    for (final record in studentsInClass) {
      final firstTerm = record.getTermResult('First Term');
      final secondTerm = record.getTermResult('Second Term');
      final thirdTerm = record.getTermResult('Third Term');

      final Map<String, List<double>> subjToTermTotals = {};
      void collect(term) {
        if (term == null) return;
        for (final s in term.subjects) {
          subjToTermTotals.putIfAbsent(s.subjectName, () => []);
          subjToTermTotals[s.subjectName]!.add(s.total);
        }
      }

      collect(firstTerm);
      collect(secondTerm);
      collect(thirdTerm);

      double sumAvg = 0;
      int subjCount = 0;
      subjToTermTotals.forEach((_, totals) {
        if (totals.isEmpty) return;
        sumAvg += totals.reduce((a, b) => a + b) / totals.length;
        subjCount++;
      });

      if (subjCount > 0) {
        allStudentAverages.add(sumAvg / subjCount);
      }
    }

    final classAverage = allStudentAverages.isEmpty
        ? 0.0
        : allStudentAverages.reduce((a, b) => a + b) /
              allStudentAverages.length;
    final highestScore = allStudentAverages.isEmpty
        ? 0.0
        : allStudentAverages.reduce((a, b) => a > b ? a : b);
    final lowestScore = allStudentAverages.isEmpty
        ? 0.0
        : allStudentAverages.reduce((a, b) => a < b ? a : b);

    return Scrollbar(
      controller: horizontalController,
      thumbVisibility: !(context.isDesktop || context.isPad),
      trackVisibility: !(context.isDesktop || context.isPad),
      interactive: true,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: SingleChildScrollView(
        controller: horizontalController,
        scrollDirection: Axis.horizontal,
        child: Container(
          width: context.isDesktop || context.isPad
              ? (context.screenWidth - 32)
              : 800,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            border: Border.all(color: KitColors.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: LogoDisplay(logo: appState.schoolInfo.logoPath),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          appState.schoolInfo.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        _keyValue('motto', appState.schoolInfo.motto),
                        _keyValue('address', appState.schoolInfo.address),
                        if (appState.schoolInfo.contactInfo.email.isNotEmpty)
                          _keyValue(
                            'email',
                            appState.schoolInfo.contactInfo.email,
                          ),
                        if (appState.schoolInfo.website.isNotEmpty)
                          _keyValue('website', appState.schoolInfo.website),
                        if (appState.schoolInfo.contactInfo.phone1.isNotEmpty ||
                            appState.schoolInfo.contactInfo.phone2.isNotEmpty)
                          _keyValue(
                            'phone',
                            [
                              if (appState
                                  .schoolInfo
                                  .contactInfo
                                  .phone1
                                  .isNotEmpty)
                                appState.schoolInfo.contactInfo.phone1,
                              if (appState
                                  .schoolInfo
                                  .contactInfo
                                  .phone2
                                  .isNotEmpty)
                                appState.schoolInfo.contactInfo.phone2,
                            ].join(', '),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              _horizontalLine(),

              // Student info
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: .5, color: KitColors.neutral200),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _keyValue('Name', studentRecord.student.name),
                            _keyValue('Gender', studentRecord.student.gender),
                            if (studentRecord.student.age.isNotNullOrZero)
                              _keyValue(
                                'Age',
                                studentRecord.student.age.toString(),
                              ),
                            _keyValue('Term', 'Third Term'),
                            _keyValue('Session', classSection.session),
                            _keyValue('Class', classSection.name),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _keyValue(
                              'Total Score',
                              (sumOfSubjectAverages).clean(),
                            ),
                            _keyValue('Class Average', classAverage.clean()),
                            _keyValue('Highest In Class', highestScore.clean()),
                            _keyValue('Lowest In Class', lowestScore.clean()),
                            _keyValue(
                              'No. in Class',
                              studentsInClass.length.toString(),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _keyValue(
                              'Final Grade',
                              appState.schoolInfo.gradingSystem.gradeForScore(
                                overallAverage,
                              ),
                            ),
                            _keyValue('Final Average', overallAverage.clean()),
                            if (appState.schoolInfo.showFinalPosition) ...[
                              _keyValue('Final Position', () {
                                final positions =
                                    studentsInClass.map((r) {
                                      final ft = r.getTermResult('First Term');
                                      final st = r.getTermResult('Second Term');
                                      final tt = r.getTermResult('Third Term');
                                      final Map<String, List<double>> m = {};
                                      void collect(term) {
                                        if (term == null) return;
                                        for (final s in term.subjects) {
                                          m.putIfAbsent(
                                            s.subjectName,
                                            () => [],
                                          );
                                          m[s.subjectName]!.add(s.total);
                                        }
                                      }

                                      collect(ft);
                                      collect(st);
                                      collect(tt);
                                      double sumAvg = 0;
                                      int subjCount = 0;
                                      m.forEach((_, totals) {
                                        if (totals.isEmpty) return;
                                        sumAvg +=
                                            totals.reduce((a, b) => a + b) /
                                            totals.length;
                                        subjCount++;
                                      });
                                      final avg = subjCount > 0
                                          ? sumAvg / subjCount
                                          : 0.0;
                                      return (avg, r.student.id);
                                    }).toList()..sort(
                                      (a, b) => b.$1.compareTo(a.$1),
                                    );

                                int position = 1;
                                for (int i = 0; i < positions.length; i++) {
                                  if (positions[i].$2 ==
                                      studentRecord.student.id) {
                                    position = i + 1;
                                    break;
                                  }
                                }
                                return TermResult.getOrdinalPosition(position);
                              }()),
                            ],
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_keyValue('Branch', classSection.branch)],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _horizontalLine(),

              // Subject table
              Table(
                border: TableBorder.all(width: .5, color: KitColors.neutral200),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1),
                  6: FlexColumnWidth(1),
                  7: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: [
                      _cell('Subjects', bold: true),
                      _cell('1st Term', bold: true),
                      _cell('2nd Term', bold: true),
                      _cell('3rd Term', bold: true),
                      _cell('AVG (100)', bold: true),
                      _cell('POS', bold: true),
                      _cell('Grade', bold: true),
                      _cell('Remark', bold: true),
                    ],
                  ),
                  ...subjectScores.entries.map((entry) {
                    final subjectName = entry.key;
                    final scores = entry.value;

                    // Calculate average for this subject
                    final validScores = scores.where((s) => s != null).toList();
                    final subjectAverage = validScores.isEmpty
                        ? 0.0
                        : (validScores.reduce((a, b) => a! + b!)! /
                              validScores.length);

                    // Get the first term result to access subject properties
                    SubjectPerformance? subjectPerf;
                    if (firstTermResult != null) {
                      try {
                        subjectPerf = firstTermResult.subjects.firstWhere(
                          (s) => s.subjectName == subjectName,
                        );
                      } catch (_) {}
                    }
                    if (subjectPerf == null && secondTermResult != null) {
                      try {
                        subjectPerf = secondTermResult.subjects.firstWhere(
                          (s) => s.subjectName == subjectName,
                        );
                      } catch (_) {}
                    }
                    if (subjectPerf == null && thirdTermResult != null) {
                      try {
                        subjectPerf = thirdTermResult.subjects.firstWhere(
                          (s) => s.subjectName == subjectName,
                        );
                      } catch (_) {}
                    }

                    return TableRow(
                      children: [
                        _cell(subjectName),
                        _cell(scores[0]?.clean() ?? '-'),
                        _cell(scores[1]?.clean() ?? '-'),
                        _cell(scores[2]?.clean() ?? '-'),
                        _cell(subjectAverage.clean()),
                        () {
                          final list =
                              subjectAverageTotalsMap[subjectName] ?? [];
                          if (list.isEmpty) return _cell('-');
                          final sorted = [...list]
                            ..sort((a, b) => b.compareTo(a));
                          int pos = 1;
                          for (int i = 0; i < sorted.length; i++) {
                            if ((sorted[i] - subjectAverage).abs() < 0.0001) {
                              pos = i + 1;
                              break;
                            }
                          }
                          return _cell(TermResult.getOrdinalPosition(pos));
                        }(),
                        () {
                          final grading = appState.schoolInfo.gradingSystem;
                          final grade = grading.gradeForScore(subjectAverage);
                          final range = grading.rangeForScore(subjectAverage);
                          final color = Color(range.color.asInt);
                          return _cell(
                            grade.isNotEmpty ? grade : '-',
                            color: color,
                          );
                        }(),
                        () {
                          final remark = appState.schoolInfo.gradingSystem
                              .rangeForScore(subjectAverage)
                              .remark;
                          return _cell(remark.isNotEmpty ? remark : '-');
                        }(),
                      ],
                    );
                  }),
                ],
              ),

              _horizontalLine(),

              Row(
                children: [
                  Expanded(
                    child: _keyValue(
                      'Grade Details',
                      appState.schoolInfo.gradingSystem.prettyPrint,
                      align: TextAlign.start,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _keyValue('No. of Subjects', subjectScores.length.toString()),
                ],
              ),

              _horizontalLine(),
              _keyValue('Class Teacher', classSection.teacherName),
              const SizedBox(height: 5),
              _keyValue(
                'Class Teacher Comment',
                appState.schoolInfo.gradingSystem
                    .rangeForScore(overallAverage)
                    .teacherRemark,
              ),
              const SizedBox(height: 5),
              _keyValue(
                "Principal's Comment",
                appState.schoolInfo.gradingSystem
                    .rangeForScore(overallAverage)
                    .principalRemark,
              ),
              _horizontalLine(),
              _keyValue("Principal's Signature", ''),
              const YGap(30),
            ],
          ),
        ),
      ),
    );
  }
}
