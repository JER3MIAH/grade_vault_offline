import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class AddStudentDialog extends HookConsumerWidget {
  final Student? student;
  final String classId;
  const AddStudentDialog({super.key, this.student, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final notifier = ref.read(appStateProvider.notifier);
    final displayError = useState<bool>(false);
    final selectedValue = useState<String?>(student?.gender);
    final fullNameController = useTextEditingController(text: student?.name);
    final ageController = useTextEditingController(
      text: student?.age.toString(),
    );

    return Form(
      key: formKey,
      child: DialogActionColumn(
        title: 'Add Student',
        primaryButtonTitle: 'Save',
        onTap: () {
          displayError.value = false;
          if (!(formKey.currentState?.validate() ?? false)) {
            return;
          }

          if (fullNameController.text.isEmpty ||
              selectedValue.value.isNullOrEmpty) {
            displayError.value = true;
            return;
          }
          if (student != null) {
            notifier.updateStudent(
              studentId: student!.id,
              name: fullNameController.text,
              age: int.tryParse(ageController.text) ?? 0,
              gender: selectedValue.value!,
            );
          } else {
            notifier.addStudent(
              classId: classId,
              name: fullNameController.text,
              gender: selectedValue.value!,
              age: int.tryParse(ageController.text) ?? 0,
            );
          }

          if (context.mounted) {
            context.pop();
            context.showSuccessSnackBar(
              '${fullNameController.text} added successfully',
            );
          }
        },
        children: [
          OutlinedTextField(
            controller: fullNameController,
            labelText: 'Full Name',
            hintText: 'Enter full name',
            validator: (value) {
              // TODO: Add this logic to package
              if (value != null &&
                  value.isNotEmpty &&
                  RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Text cannot be only numbers';
              }
              return Validators.validateRequiredText(value);
            },
            validateOnBuild: student == null,
          ),
          const YGap(12),
          OutlinedTextField(
            controller: ageController,
            labelText: 'Age (Optional)',
            hintText: 'Enter age',
            keyboardType: TextInputType.number,
            validator: (value) =>
                Validators.validateNumber(value, isOptional: true),
            validateOnBuild: false,
          ),
          const YGap(12),
          KitSelector(
            hintText: 'Gender',
            value: selectedValue.value,
            items: ['Male', 'Female'],
            onChanged: (selected) {
              selectedValue.value = selected;
            },
          ),
          const YGap(12),
          ErrorContainer(
            title: 'Please fill all required fields',
            show: displayError.value,
          ),
        ],
      ),
    );
  }
}
