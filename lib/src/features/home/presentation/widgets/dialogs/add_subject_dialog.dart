import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/core/constants/subject_list.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AddSubjectDialog extends HookConsumerWidget {
  final List<String> existingSubjects;
  const AddSubjectDialog({super.key, this.existingSubjects = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customSubjects = ref.watch(
      appStateProvider.select((s) => s.schoolInfo.customSubjects),
    );

    final allSubjects = [
      ...SUBJECT_LIST,
      ...customSubjects.where((s) => !SUBJECT_LIST.contains(s)),
    ];

    final showError = useState<bool>(false);
    final selectedValues = useState<List<String>>(existingSubjects);

    return DialogActionColumn(
      title: 'Add Subject',
      primaryButtonTitle: 'Save',
      onTap: () {
        showError.value = false;
        if (selectedValues.value.isEmpty) {
          showError.value = true;
          return;
        }
        context.pop(selectedValues.value);
      },
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250),
          child: KitMultiSelector(
            selectedValues: selectedValues.value,
            items: allSubjects,
            isDropdown: false,
            addNewPlaceholder: 'Add New Subject',
            onChanged: (newSelected) => selectedValues.value = newSelected,
          ),
        ),
        const YGap(12),
        ErrorContainer(
          title: 'Please select at least one subject',
          show: showError.value,
        ),
      ],
    );
  }
}
