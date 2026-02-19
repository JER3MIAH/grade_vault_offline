import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/providers.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class CreateNewClassDialog extends HookConsumerWidget {
  final ClassSection? classSection;
  const CreateNewClassDialog({super.key, this.classSection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final showError = useState<bool>(false);
    final selectedSession = useState<String?>(classSection?.session);
    final selectedBranch = useState<String?>(classSection?.branch);
    final className = useTextEditingController(text: classSection?.name ?? '');
    final teacherName = useTextEditingController(
      text: classSection?.teacherName ?? '',
    );

    return Form(
      key: formKey,
      child: DialogActionColumn(
        title: 'Create New Class',
        primaryButtonTitle: 'Create Class',
        onTap: () async {
          showError.value = false;
          if (!(formKey.currentState?.validate() ?? false)) {
            return;
          }

          if (selectedBranch.value == null && BRANCH_LIST.isNotEmpty) {
            showError.value = true;
            return;
          }

          if (selectedSession.value.isNullOrEmpty) {
            showError.value = true;
            return;
          }

          // Create the class using the notifier
          final notifier = ref.read(appStateProvider.notifier);
          await notifier.createClass(
            name: className.text,
            teacherName: teacherName.text,
            branch: selectedBranch.value ?? '',
            session: selectedSession.value ?? '',
          );

          if (context.mounted) {
            context.pop();
            context.showSuccessSnackBar(
              '${className.text} created successfully',
            );
          }
        },
        children: [
          OutlinedTextField(
            controller: className,
            labelText: 'Class Name',
            hintText: 'Enter class name',
            validateOnBuild: classSection == null,
            validator: Validators.validateRequiredText,
          ),
          const YGap(12),
          OutlinedTextField(
            controller: teacherName,
            labelText: 'Teacher Name',
            hintText: 'Enter teacher\'s name',
            validateOnBuild: classSection == null,
            validator: Validators.validateRequiredText,
          ),
          const YGap(12),
          AppSelector(
            hintText: 'Academic Session',
            value: selectedSession.value,
            items: SESSION_LIST,

            onChanged: (selected) {
              selectedSession.value = selected ?? CURRENT_SESSION;
            },
          ),
          const YGap(12),
          if (BRANCH_LIST.isNotEmpty)
            AppSelector(
              hintText: 'Branch',
              value: selectedBranch.value,
              items: BRANCH_LIST,
              onChanged: (value) {
                selectedBranch.value = value;
              },
            ),
          const YGap(12),
          ErrorContainer(
            title: 'Please fill all required fields',
            show: showError.value,
          ),
        ],
      ),
    );
  }
}
