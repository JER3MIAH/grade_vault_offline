import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';
import 'package:grade_vault_offline/src/core/navigation/app_routes.dart';
import 'package:grade_vault_offline/src/features/home/data/models/class_section.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/features/home/presentation/widgets/dialogs/delete_class_dialog.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class ClassSettingsDialog extends HookConsumerWidget {
  final ClassSection classSection;
  const ClassSettingsDialog({super.key, required this.classSection});

  @override
  Widget build(BuildContext context, ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final showError = useState<bool>(false);
    final notifier = ref.read(appStateProvider.notifier);
    final teacherName = useTextEditingController(
      text: classSection.teacherName,
    );
    final className = useTextEditingController(text: classSection.name);
    final selectedSession = useState<String?>(classSection.session);
    final selectedBranch = useState<String?>(classSection.branch);

    return Form(
      key: formKey,
      child: DialogActionColumn(
        title: 'Class Settings',
        primaryButtonTitle: 'Save',
        onTap: () {
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
          notifier.updateClassProperties(
            classId: classSection.id,
            className: className.text.trim(),
            teacherName: teacherName.text.trim(),
            branch: selectedBranch.value,
            session: selectedSession.value,
          );
          context.pop();
          context.showSuccessSnackBar('Class settings updated successfully');
        },
        children: [
          OutlinedTextField(
            controller: teacherName,
            labelText: 'Teacher Name',
            hintText: 'Enter teacher name',
          ),
          const YGap(8),
          OutlinedTextField(
            controller: className,
            labelText: 'Class Name',
            hintText: 'Enter class name',
          ),
          const YGap(8),
          AppSelector(
            hintText: 'Session',
            value: selectedSession.value,
            items: SESSION_LIST,
            onChanged: (value) {
              selectedSession.value = value;
            },
          ),

          if (BRANCH_LIST.isNotEmpty) ...[
            const YGap(8),
            AppSelector(
              hintText: 'Branch',
              value: selectedBranch.value,
              items: BRANCH_LIST,
              onChanged: (value) {
                selectedBranch.value = value;
              },
            ),
          ],
          ErrorContainer(
            title: 'Please fill all required fields',
            show: showError.value,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: AppColors.neutral200, height: .5),
          ),
          PrimaryButton(
            title: 'Delete Class',
            icon: CupertinoIcons.trash,
            color: AppColors.red500,
            onTap: () {
              context.showDialog(
                DeleteItemDialog(
                  type: 'Class',
                  onDelete: () {
                    context.popUntilRoute(AppRoutes.home);
                    notifier.deleteClass(classSection.id);
                    context.showSuccessSnackBar(
                      '${classSection.name} deleted successfully',
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
