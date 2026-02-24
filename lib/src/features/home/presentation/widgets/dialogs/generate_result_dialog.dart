import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';
import 'package:grade_vault_offline/src/core/license/license_notifier.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/features/onboarding/license_management_dialog.dart';
import 'package:grade_vault_offline/src/features/settings/presentation/providers/action_tracker_notifier.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class GenerateResultDialog extends HookConsumerWidget {
  final String classId;
  const GenerateResultDialog({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final selectedTerm = useState<String>(TERM_LIST.first);

    void pop() {
      context.pop();
    }

    return DialogActionColumn(
      title: 'Select Term',
      primaryButtonTitle: 'Generate',
      onTap: () async {
        final isDemo = ref.read(licenseProvider).isDemo;
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

        final file = await PdfHelper().generateResultPdf(
          appState: appState,
          classId: classId,
          termName: selectedTerm.value,
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
      children: [
        Text(
          'Please select the term for which you want to generate the result.',
          style: context.textTheme.bodyMedium,
        ),
        const YGap(16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Term',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          initialValue: selectedTerm.value,
          items: TERM_LIST
              .map(
                (term) =>
                    DropdownMenuItem<String>(value: term, child: Text(term)),
              )
              .toList(),
          onChanged: (val) {
            if (val == null) return;
            selectedTerm.value = val;
          },
        ),
      ],
    );
  }
}
