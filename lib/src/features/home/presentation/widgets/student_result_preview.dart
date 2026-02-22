import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';

class StudentResultPreview extends HookWidget {
  final AppState appState;
  final String classId;
  final String studentId;
  final String termName;

  const StudentResultPreview({
    super.key,
    required this.appState,
    required this.classId,
    required this.studentId,
    required this.termName,
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
    // Resolve class, student and term
    ClassSection? classSection;
    StudentRecord? studentRecord;
    TermResult? termResult;

    try {
      classSection = appState.classSections.firstWhere((c) => c.id == classId);
      studentRecord = appState.studentRecords.firstWhere(
        (s) => s.student.id == studentId,
      );
      termResult = studentRecord.getTermResult(termName);
    } catch (_) {
      classSection = null;
      studentRecord = null;
      termResult = null;
    }

    if (classSection == null || studentRecord == null || termResult == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Text(
          'Preview unavailable: missing class, student, or term data.',
        ),
      );
    }

    // Build subject totals to compute positions like in PDF
    final studentsInClass = appState.studentRecords
        .where((s) => s.classId == classId)
        .toList();
    final studentRecordsWithTerm = studentsInClass
        .where((s) => s.getTermResult(termName) != null)
        .toList();

    final Map<String, List<double>> subjectTotalsMap = {};
    for (final record in studentRecordsWithTerm) {
      final tr = record.getTermResult(termName);
      if (tr == null) continue;
      for (final subject in tr.subjects) {
        subjectTotalsMap.putIfAbsent(subject.subjectName, () => []);
        subjectTotalsMap[subject.subjectName]!.add(subject.total);
      }
    }

    // Calculate all students' averages in the class
    final allStudentAverages = studentRecordsWithTerm.map((record) {
      final tr = record.getTermResult(termName);
      if (tr == null) return 0.0;
      final subjects = tr.subjects.map((s) => s.total).toList();
      return subjects.isEmpty
          ? 0.0
          : subjects.reduce((a, b) => a + b) / subjects.length;
    }).toList();

    // Class average is the average of all students' averages
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
    final showCa = !termResult.subjects.every((a) => a.caScore == 0);

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
                            _keyValue('Term', termName),
                            _keyValue('Session', classSection.session),
                            _keyValue('Class', classSection.name),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _keyValue(
                              'Total Score',
                              termResult.totalScore.clean(),
                            ),
                            _keyValue('Class Average', classAverage.clean()),
                            _keyValue('Highest In Class', highestScore.clean()),
                            _keyValue('Lowest In Class', lowestScore.clean()),
                            _keyValue(
                              'No. in Class',
                              studentRecordsWithTerm.length.toString(),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _keyValue('Final Grade', termResult.grade),
                            _keyValue(
                              'Final Average',
                              termResult.average.clean(),
                            ),
                            if (appState.schoolInfo.showFinalPosition)
                              _keyValue('Final Position', () {
                                final positions =
                                    studentRecordsWithTerm
                                        .map(
                                          (r) => (
                                            r
                                                    .getTermResult(termName)
                                                    ?.average ??
                                                0.0,
                                            r.student.id,
                                          ),
                                        )
                                        .toList()
                                      ..sort((a, b) => b.$1.compareTo(a.$1));

                                int position = 1;
                                for (int i = 0; i < positions.length; i++) {
                                  if (positions[i].$2 == studentId) {
                                    position = i + 1;
                                    break;
                                  }
                                }
                                return TermResult.getOrdinalPosition(position);
                              }()),
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
                  6: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: [
                      _cell('Subjects', bold: true),
                      if (showCa) _cell('CA'),
                      _cell('Exam'),
                      _cell('Total'),
                      _cell('POS'),
                      _cell('Grade'),
                      _cell('Remark'),
                    ],
                  ),
                  ...termResult.subjects.map((subject) {
                    return TableRow(
                      children: [
                        _cell(subject.subjectName),
                        if (showCa) _cell(subject.caScore.clean()),
                        _cell(subject.examScore.clean()),
                        _cell(subject.total.clean()),
                        _cell(
                          subject.getPosition(
                            subjectTotalsMap[subject.subjectName] ?? [],
                          ),
                        ),
                        _cell(subject.grade, color: Color(subject.remarkColor)),
                        _cell(subject.remark),
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
                  _keyValue(
                    'No. of Subjects',
                    termResult.numberOfSubjects.toString(),
                  ),
                ],
              ),

              _horizontalLine(),
              _keyValue('Class Teacher', classSection.teacherName),
              const SizedBox(height: 5),
              _keyValue(
                'Class Teacher Comment',
                termResult.displayTeacherComment,
              ),
              const SizedBox(height: 5),
              _keyValue(
                "Principal's Comment",
                termResult.displayPrincipalComment,
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
