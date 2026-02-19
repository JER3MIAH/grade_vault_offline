import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:grade_vault_offline/src/features/home/data/models/app_state.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class PdfHelper {
  pw.Widget _cell(String text, {bool bold = false, PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  String _getOrdinalPosition(int position) {
    if (position <= 0) return '';
    if (position % 100 >= 11 && position % 100 <= 13) {
      return '${position}th';
    }
    switch (position % 10) {
      case 1:
        return '${position}st';
      case 2:
        return '${position}nd';
      case 3:
        return '${position}rd';
      default:
        return '${position}th';
    }
  }

  pw.Widget _horizontalLine() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 16),
      height: .5,
      width: double.infinity,
      color: PdfColors.grey100,
    );
  }

  pw.Widget _keyValue(
    String key,
    String value, {
    pw.TextAlign align = pw.TextAlign.center,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.RichText(
        textAlign: align,
        text: pw.TextSpan(
          text: '$key: ',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          children: [
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File?> generateBroadSheetPdf({
    required AppState appState,
    required String classId,
  }) async {
    try {
      final pdf = pw.Document();
      final logoBytes = await rootBundle.load('assets/sunflower_icon.png');
      final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

      final schoolLogo = pw.SizedBox(
        width: 100,
        height: 100,
        child: pw.Image(logoImage),
      );

      // Get the specific class
      final classSection = appState.classSections.firstWhere(
        (c) => c.id == classId,
        orElse: () => throw Exception('Class not found: $classId'),
      );

      // Get all students in this class
      final studentsInClass = appState.studentRecords
          .where((s) => s.classId == classId)
          .toList();

      // Generate one page per student
      for (final studentRecord in studentsInClass) {
        final student = studentRecord.student;

        // Collect term results for all three terms
        final firstTermResult = studentRecord.getTermResult('First Term');
        final secondTermResult = studentRecord.getTermResult('Second Term');
        final thirdTermResult = studentRecord.getTermResult('Third Term');

        // Build a map of subject name -> [term1Total, term2Total, term3Total]
        final Map<String, List<double?>> subjectScores = {};

        // Helper to add subjects from a term
        void addSubjectsFromTerm(termResult, int termIndex) {
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
        if (subjectScores.isEmpty) continue;

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

        // Calculate statistics for broadsheet (across all terms)
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

        pdf.addPage(
          pw.Page(
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              return pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey100),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        schoolLogo,
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text(
                                appState.schoolInfo.name,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.normal,
                                ),
                              ),
                              _keyValue('motto', appState.schoolInfo.motto),
                              _keyValue('address', appState.schoolInfo.address),
                              if (appState
                                  .schoolInfo
                                  .contactInfo
                                  .email
                                  .isNotEmpty)
                                _keyValue(
                                  'email',
                                  appState.schoolInfo.contactInfo.email,
                                ),
                              if (appState.schoolInfo.website.isNotEmpty)
                                _keyValue(
                                  'website',
                                  appState.schoolInfo.website,
                                ),
                              if (appState
                                      .schoolInfo
                                      .contactInfo
                                      .phone1
                                      .isNotEmpty ||
                                  appState
                                      .schoolInfo
                                      .contactInfo
                                      .phone2
                                      .isNotEmpty)
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

                    // STUDENT INFO
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          width: .5,
                          color: PdfColors.grey100,
                        ),
                      ),
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _keyValue('Name', student.name),
                                  _keyValue('Gender', student.gender),
                                  if (student.age.isNotNullOrZero)
                                    _keyValue('Age', student.age.toString()),
                                  _keyValue('Term', 'Third Term'),
                                  _keyValue('Session', classSection.session),
                                  _keyValue('Class', classSection.name),
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _keyValue(
                                    'Total Score',
                                    sumOfSubjectAverages.clean(),
                                  ),
                                  _keyValue(
                                    'Class Average',
                                    classAverage.clean(),
                                  ),
                                  _keyValue(
                                    'Highest In Class',
                                    highestScore.clean(),
                                  ),
                                  _keyValue(
                                    'Lowest In Class',
                                    lowestScore.clean(),
                                  ),
                                  _keyValue(
                                    'No. in Class',
                                    studentsInClass.length.toString(),
                                  ),
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _keyValue(
                                    'Final Grade',
                                    appState.schoolInfo.gradingSystem
                                        .gradeForScore(overallAverage),
                                  ),
                                  _keyValue(
                                    'Final Average',
                                    overallAverage.clean(),
                                  ),
                                  if (appState
                                      .schoolInfo
                                      .showFinalPosition) ...[
                                    _keyValue('Final Position', () {
                                      final positions =
                                          studentsInClass.asMap().entries.map((
                                            e,
                                          ) {
                                            final ft = e.value.getTermResult(
                                              'First Term',
                                            );
                                            final st = e.value.getTermResult(
                                              'Second Term',
                                            );
                                            final tt = e.value.getTermResult(
                                              'Third Term',
                                            );
                                            final Map<String, List<double>> m =
                                                {};
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
                                                  totals.reduce(
                                                    (a, b) => a + b,
                                                  ) /
                                                  totals.length;
                                              subjCount++;
                                            });
                                            final avg = subjCount > 0
                                                ? sumAvg / subjCount
                                                : 0.0;
                                            return (avg, e.value.student.id);
                                          }).toList()..sort(
                                            (a, b) => b.$1.compareTo(a.$1),
                                          );

                                      int position = 1;
                                      for (
                                        int i = 0;
                                        i < positions.length;
                                        i++
                                      ) {
                                        if (positions[i].$2 == student.id) {
                                          position = i + 1;
                                          break;
                                        }
                                      }
                                      return _getOrdinalPosition(position);
                                    }()),
                                  ],
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _keyValue('Branch', classSection.branch),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    _horizontalLine(),

                    // SUBJECT TABLE
                    pw.Table(
                      border: pw.TableBorder.all(
                        width: .5,
                        color: PdfColors.grey100,
                      ),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1),
                        3: const pw.FlexColumnWidth(1),
                        4: const pw.FlexColumnWidth(1),
                        5: const pw.FlexColumnWidth(1),
                        6: const pw.FlexColumnWidth(1),
                        7: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey100,
                          ),
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
                          final validScores = scores
                              .where((s) => s != null)
                              .toList();
                          final subjectAverage = validScores.isEmpty
                              ? 0.0
                              : (validScores.reduce((a, b) => a! + b!)! /
                                    validScores.length);

                          // Get the first term result to access subject properties
                          dynamic subjectPerf;
                          if (firstTermResult != null) {
                            try {
                              subjectPerf = firstTermResult.subjects.firstWhere(
                                (s) => s.subjectName == subjectName,
                              );
                            } catch (_) {}
                          }
                          if (subjectPerf == null && secondTermResult != null) {
                            try {
                              subjectPerf = secondTermResult.subjects
                                  .firstWhere(
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

                          return pw.TableRow(
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
                                  if ((sorted[i] - subjectAverage).abs() <
                                      0.0001) {
                                    pos = i + 1;
                                    break;
                                  }
                                }
                                return _cell(_getOrdinalPosition(pos));
                              }(),
                              () {
                                final grading =
                                    appState.schoolInfo.gradingSystem;
                                final grade = grading.gradeForScore(
                                  subjectAverage,
                                );
                                final range = grading.rangeForScore(
                                  subjectAverage,
                                );
                                final color = PdfColor.fromInt(
                                  range.color.asInt,
                                );
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

                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _keyValue(
                            'Grade Details',
                            appState.schoolInfo.gradingSystem.prettyPrint,
                            align: pw.TextAlign.start,
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        _keyValue(
                          'No. of Subjects',
                          subjectScores.length.toString(),
                        ),
                      ],
                    ),

                    _horizontalLine(),
                    _keyValue('Class Teacher', classSection.teacherName),
                    pw.SizedBox(height: 5),
                    _keyValue(
                      'Class Teacher Comment',
                      appState.schoolInfo.gradingSystem
                          .rangeForScore(overallAverage)
                          .teacherRemark,
                    ),
                    pw.SizedBox(height: 5),
                    _keyValue(
                      'Principal\'s Comment',
                      appState.schoolInfo.gradingSystem
                          .rangeForScore(overallAverage)
                          .principalRemark,
                    ),
                    _horizontalLine(),
                    _keyValue('Principal\'s Signature', ''),
                  ],
                ),
              );
            },
          ),
        );
      }

      final sanitizedTitle =
          '${classSection.branch}_${classSection.name}_BroadSheet_${classSection.session}'
              .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '')
              .trim();
      final pdfBytes = await pdf.save();
      if (kIsWeb) {
        // 🌐 Flutter Web → trigger download
        saveFileWeb(pdfBytes, '$sanitizedTitle.pdf');
        log('Broad Sheet PDF downloaded (web)');

        return null; // No File on web
      }
      final dir = await getDir();
      final file = await _getUniqueFile(dir!.path, sanitizedTitle);

      log('Saving Broad Sheet PDF to: ${file.path}');

      await file.writeAsBytes(pdfBytes);
      log('File exists after save: ${await file.exists()}');

      return file;
    } catch (e, stack) {
      log('Error generating broad sheet pdf: $e with stack: $stack');
      return null;
    }
  }

  Future<File?> generateResultPdf({
    required AppState appState,
    required String classId,
    required String termName,
  }) async {
    try {
      final pdf = pw.Document();
      final logoBytes = await rootBundle.load('assets/sunflower_icon.png');
      final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

      final schoolLogo = pw.SizedBox(
        width: 100,
        height: 100,
        child: pw.Image(logoImage),
      );

      // Get the specific class
      final classSection = appState.classSections.firstWhere(
        (c) => c.id == classId,
        orElse: () => throw Exception('Class not found: $classId'),
      );

      // Get all students in this class
      final studentsInClass = appState.studentRecords
          .where((s) => s.classId == classId)
          .toList();

      // Get term results for all students in this class
      final studentRecordsWithTerm = studentsInClass
          .where((s) => s.getTermResult(termName) != null)
          .toList();

      // Build subject totals for this term across all students
      final Map<String, List<double>> subjectTotalsMap = {};

      for (final record in studentRecordsWithTerm) {
        final termResult = record.getTermResult(termName);
        if (termResult != null) {
          for (final subject in termResult.subjects) {
            subjectTotalsMap.putIfAbsent(subject.subjectName, () => []);
            subjectTotalsMap[subject.subjectName]!.add(subject.total);
          }
        }
      }

      // Generate one page per student
      for (final studentRecord in studentRecordsWithTerm) {
        final termResult = studentRecord.getTermResult(termName);
        if (termResult == null) continue;

        final student = studentRecord.student;

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

        pdf.addPage(
          pw.Page(
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              return pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey100),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        schoolLogo,
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text(
                                appState.schoolInfo.name,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.normal,
                                ),
                              ),
                              _keyValue('motto', appState.schoolInfo.motto),
                              _keyValue('address', appState.schoolInfo.address),
                              if (appState
                                  .schoolInfo
                                  .contactInfo
                                  .email
                                  .isNotEmpty)
                                _keyValue(
                                  'email',
                                  appState.schoolInfo.contactInfo.email,
                                ),
                              if (appState.schoolInfo.website.isNotEmpty)
                                _keyValue(
                                  'website',
                                  appState.schoolInfo.website,
                                ),
                              if (appState
                                      .schoolInfo
                                      .contactInfo
                                      .phone1
                                      .isNotEmpty ||
                                  appState
                                      .schoolInfo
                                      .contactInfo
                                      .phone2
                                      .isNotEmpty)
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
                    // STUDENT INFO
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          width: .5,
                          color: PdfColors.grey100,
                        ),
                      ),
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _keyValue('Name', student.name),
                                  _keyValue('Gender', student.gender),
                                  if (student.age.isNotNullOrZero)
                                    _keyValue('Age', student.age.toString()),
                                  _keyValue('Term', termName),
                                  _keyValue('Session', classSection.session),
                                  _keyValue('Class', classSection.name),
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _keyValue(
                                    'Total Score',
                                    termResult.totalScore.clean(),
                                  ),
                                  _keyValue(
                                    'Class Average',
                                    classAverage.clean(),
                                  ),
                                  _keyValue(
                                    'Highest In Class',
                                    highestScore.clean(),
                                  ),
                                  _keyValue(
                                    'Lowest In Class',
                                    lowestScore.clean(),
                                  ),
                                  _keyValue(
                                    'No. in Class',
                                    studentRecordsWithTerm.length.toString(),
                                  ),
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                                                          .getTermResult(
                                                            termName,
                                                          )
                                                          ?.average ??
                                                      0.0,
                                                  r.student.id,
                                                ),
                                              )
                                              .toList()
                                            ..sort(
                                              (a, b) => b.$1.compareTo(a.$1),
                                            );

                                      int position = 1;
                                      for (
                                        int i = 0;
                                        i < positions.length;
                                        i++
                                      ) {
                                        if (positions[i].$2 ==
                                            studentRecord.student.id) {
                                          position = i + 1;
                                          break;
                                        }
                                      }
                                      return _getOrdinalPosition(position);
                                    }()),
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _keyValue('Branch', classSection.branch),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    _horizontalLine(),

                    // SUBJECT TABLE
                    pw.Table(
                      border: pw.TableBorder.all(
                        width: .5,
                        color: PdfColors.grey100,
                      ),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1),
                        3: const pw.FlexColumnWidth(1),
                        4: const pw.FlexColumnWidth(1),
                        5: const pw.FlexColumnWidth(1),
                        6: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey100,
                          ),
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
                          return pw.TableRow(
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

                              _cell(
                                subject.grade,
                                color: PdfColor.fromInt(subject.remarkColor),
                              ),
                              _cell(subject.remark),
                            ],
                          );
                        }),
                      ],
                    ),

                    _horizontalLine(),

                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _keyValue(
                            'Grade Details',
                            appState.schoolInfo.gradingSystem.prettyPrint,
                            align: pw.TextAlign.start,
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        _keyValue(
                          'No. of Subjects',
                          termResult.numberOfSubjects.toString(),
                        ),
                      ],
                    ),

                    _horizontalLine(),
                    // COMMENTS
                    _keyValue('Class Teacher', classSection.teacherName),
                    pw.SizedBox(height: 5),

                    _keyValue(
                      'Class Teacher Comment',
                      termResult.displayTeacherComment,
                    ),
                    pw.SizedBox(height: 5),

                    _keyValue(
                      'Principal\'s Comment',
                      termResult.displayPrincipalComment,
                    ),
                    _horizontalLine(),
                    _keyValue('Principal\'s Signature', ''),
                  ],
                ),
              );
            },
          ),
        );
      }

      final sanitizedTitle =
          '${classSection.branch}_${classSection.name}_${termName}_${classSection.session}'
              .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '')
              .trim();

      final pdfBytes = await pdf.save();
      if (kIsWeb) {
        // 🌐 Flutter Web → trigger download
        saveFileWeb(pdfBytes, '$sanitizedTitle.pdf');
        log('Result PDF downloaded (web)');

        return null; // No File on web
      }
      final dir = await getDir();
      final file = await _getUniqueFile(dir!.path, sanitizedTitle);

      log('Saving PDF to: ${file.path}');

      await file.writeAsBytes(await pdf.save());
      log('File exists after save: ${await file.exists()}');

      return file;
    } catch (e, stack) {
      log('Error generating pdf: $e with stack: $stack');
      return null;
    }
  }
}

Future<File> _getUniqueFile(String dirPath, String baseName) async {
  int counter = 1;

  // Initial filename
  String sanitizedBase = baseName.replaceAll(
    RegExp(r'[<>:"/\\|?*\x00-\x1F]'),
    '',
  );
  String filePath = '$dirPath/$sanitizedBase.pdf';
  File file = File(filePath);

  // Keep incrementing until we find a name that doesn't exist
  while (await file.exists()) {
    filePath = '$dirPath/$sanitizedBase($counter).pdf';
    file = File(filePath);
    counter++;
  }

  return file;
}
