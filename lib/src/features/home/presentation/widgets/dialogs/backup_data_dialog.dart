import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/core/navigation/app_routes.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class BackupDataDialog extends ConsumerWidget {
  const BackupDataDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CustomTile(
            title: 'Export Local Backup',
            subtitle: 'Download JSON file',
            icon: Icons.file_download_outlined,
            onTap: () async {
              final service = BackupDataService();
              final filePath = await service.exportData(
                classes: appState.classSections,
                students: appState.studentRecords,
              );

              if (context.mounted) {
                if (filePath != null) {
                  context.showSuccessSnackBar('Backup exported to $filePath');
                } else {
                  context.showErrorSnackBar('Failed to export backup');
                }
                context.pop(); // Close backup dialog
              }
            },
          ),
          _CustomTile(
            title: 'Import Data',
            subtitle: 'Restore from JSON file',
            icon: Icons.file_upload_outlined,
            onTap: () async {
              final service = BackupDataService();
              final result = await service.importData(
                existingClasses: appState.classSections,
                existingStudents: appState.studentRecords,
              );

              if (context.mounted) {
                if (result != null) {
                  // Update app state with merged data
                  await notifier.replaceAppState(
                    appState.copyWith(
                      classSections: result.classes,
                      studentRecords: result.students,
                    ),
                  );

                  // Show summary of import
                  String message = 'Data imported successfully!';
                  if (result.duplicateInfo.isNotEmpty) {
                    message += '\n\n${result.duplicateInfo}';
                  }

                  if (context.mounted) {
                    context.showSuccessSnackBar(message);
                    context.pop(); // Close backup dialog
                  }
                } else {
                  context.showErrorSnackBar(
                    'Failed to import data or no file selected',
                  );
                }
              }
            },
          ),
          Divider(height: 8, color: Colors.grey.shade300),
          _CustomTile(
            title: 'Settings',
            subtitle: 'Manage app settings',
            icon: Icons.settings_outlined,
            onTap: () {
              context.pop();
              context.pushNamed(AppRoutes.settings);
            },
          ),
        ],
      ),
    );
  }
}

class _CustomTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _CustomTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: StyledText(title, fontSize: 16, fontWeight: FontWeight.w500),
      subtitle: StyledText(subtitle, fontSize: 14, color: KitColors.neutral500),
      leading: Icon(icon, color: KitColors.neutral500),
      onTap: onTap,
    );
  }
}
