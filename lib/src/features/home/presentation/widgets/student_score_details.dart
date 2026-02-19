import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/features/home/data/models/subject_perf.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class StudentScoreDetails extends StatelessWidget {
  final List<SubjectPerformance> performances;
  final String studentName;

  const StudentScoreDetails({
    super.key,
    required this.performances,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StyledText(studentName, fontWeight: FontWeight.bold),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(performances.length, (index) {
                  final subject = performances[index];
                  final isLast = index == performances.length - 1;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Subject Name
                          Expanded(
                            flex: 3,
                            child: Text(
                              subject.subjectName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // CA Score (if enabled)
                          if (!performances.every((p) => p.caScore == 0))
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'CA',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    subject.caScore.clean(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),

                          // Exam Score
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Exam',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  subject.examScore.clean(),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),

                          // Total Score
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  subject.total.clean(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(subject.remarkColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!isLast) const Divider(),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
