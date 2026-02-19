import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:grade_vault_offline/src/features/home/data/models/subject_perf.dart';
import 'package:grade_vault_offline/src/features/home/data/models/term_result.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';

class EditScoresDialog extends HookConsumerWidget {
  final TermResult termResult;
  final String studentId;
  final String termName;

  const EditScoresDialog({
    super.key,
    required this.termResult,
    required this.studentId,
    required this.termName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final includeCa = useState<bool>(true);
    final animation = useAnimationController(
      duration: const Duration(milliseconds: 180),
    )..forward();

    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);

    final performances = termResult.subjects;

    final caControllers = useMemoized(() {
      return performances.map((sp) {
        return TextEditingController(
          text: sp.caScore == 0 ? '' : sp.caScore.clean(),
        );
      }).toList();
    });

    final examControllers = useMemoized(() {
      return performances.map((sp) {
        return TextEditingController(
          text: sp.examScore == 0 ? '' : sp.examScore.clean(),
        );
      }).toList();
    });

    return Form(
      key: formKey,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: FadeTransition(
          opacity: fade,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ---------- TITLE ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const StyledText(
                        'Edit Scores',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const StyledText('Include CA', fontSize: 16),
                          Switch.adaptive(
                            value: includeCa.value,
                            activeThumbColor: AppColors.white,
                            activeTrackColor: context.colors.primary,
                            onChanged: (v) {
                              includeCa.value = v;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const YGap(20),

                  // ---------- SUBJECT FIELDS ----------
                  Column(
                    children: [
                      for (int i = 0; i < performances.length; i++)
                        _SubjectEditorCard(
                          index: i,
                          subject: performances[i],
                          includeCa: includeCa.value,
                          caController: caControllers[i],
                          examController: examControllers[i],
                        ),
                    ],
                  ),

                  const YGap(20),

                  // ---------- SAVE BUTTON ----------
                  PrimaryButton(
                    expanded: true,
                    title: 'Save',
                    onTap: () async {
                      if (!(formKey.currentState?.validate() ?? true)) return;

                      final updatedList = <SubjectPerformance>[];

                      for (int i = 0; i < performances.length; i++) {
                        final ca = includeCa.value
                            ? double.tryParse(caControllers[i].text) ?? 0.0
                            : 0.0;

                        final exam =
                            double.tryParse(examControllers[i].text) ?? 0.0;

                        updatedList.add(
                          performances[i].copyWith(
                            caScore: ca,
                            examScore: exam,
                          ),
                        );
                      }

                      // Update scores in AppState
                      final notifier = ref.read(appStateProvider.notifier);
                      await notifier.updateSubjectScores(
                        studentId: studentId,
                        termName: termName,
                        subjectPerformances: updatedList,
                      );

                      if (context.mounted) {
                        context.pop();
                        context.showSuccessSnackBar(
                          'Scores updated successfully',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectEditorCard extends HookWidget {
  final int index;
  final SubjectPerformance subject;
  final bool includeCa;
  final TextEditingController caController;
  final TextEditingController examController;

  const _SubjectEditorCard({
    required this.index,
    required this.subject,
    required this.includeCa,
    required this.caController,
    required this.examController,
  });

  @override
  Widget build(BuildContext context) {
    final total = useState(subject.total);

    void recomputeTotal() {
      final ca = includeCa ? double.tryParse(caController.text) ?? 0 : 0;
      final exam = double.tryParse(examController.text) ?? 0;
      total.value = ca + exam;
    }

    useEffect(() {
      caController.addListener(recomputeTotal);
      examController.addListener(recomputeTotal);

      return () {
        caController.removeListener(recomputeTotal);
        examController.removeListener(recomputeTotal);
      };
    }, []);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: context.paddingAllMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject title
            Text(
              subject.subjectName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const YGap(8),

            Row(
              spacing: 8,
              children: [
                if (includeCa)
                  Expanded(
                    child: OutlinedTextField(
                      controller: caController,
                      keyboardType: TextInputType.number,
                      labelText: 'CA Score',
                      hintText: 'Enter CA score',
                      validator: (_) => Validators.validateNumericFieldsTotal([
                        includeCa ? caController.text.trim() : '0',
                        examController.text.trim(),
                      ]),
                    ),
                  ),
                Expanded(
                  child: OutlinedTextField(
                    controller: examController,
                    keyboardType: TextInputType.number,
                    labelText: 'Exam Score',
                    hintText: 'Enter exam score',
                    validator: (_) => Validators.validateNumericFieldsTotal([
                      includeCa ? caController.text.trim() : '0',
                      examController.text.trim(),
                    ]),
                  ),
                ),
              ],
            ),

            const YGap(8),

            // LIVE total
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Total: ${total.value.clean()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
