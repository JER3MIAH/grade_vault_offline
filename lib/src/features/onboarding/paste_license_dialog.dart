import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/core/license/license_notifier.dart';
import 'package:grade_vault_offline/src/features/home/data/models/school_info.dart';
import 'package:grade_vault_offline/src/shared/utils/license_file_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toolkit_core/toolkit_core.dart';
// Import the helper created above
// import 'package:grade_vault_offline/src/core/utils/license_file_helper.dart';

class PasteLicenseDialog extends HookConsumerWidget {
  final Function(SchoolInfo) onSuccess;

  const PasteLicenseDialog({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVerifying = useState(false);
    final licenseString = useState<String?>(null);
    final fileName = useState<String?>(null);

    return AlertDialog(
      title: const Text('Upload License File'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please select the .txt license file sent to your email.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isVerifying.value
                  ? null
                  : () async {
                      // Destructure the record directly from the helper
                      final res = await LicenseFileHelper.pickAndReadLicense();

                      if (res != null) {
                        fileName.value = res.name;
                        licenseString.value = res.content;
                      }
                    },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: fileName.value != null
                        ? Colors.blue.shade300
                        : KitColors.neutral300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: fileName.value != null
                      ? Colors.blue.withValues(alpha: 0.05)
                      : KitColors.neutral50,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: fileName.value != null ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName.value ?? 'Click to select license.txt',
                        style: TextStyle(
                          fontWeight: fileName.value != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: fileName.value != null
                              ? Colors.black
                              : Colors.grey,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (fileName.value != null)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (isVerifying.value || licenseString.value == null)
              ? null
              : () async {
                  isVerifying.value = true;
                  try {
                    // Slight delay for UX feedback
                    await Future.delayed(const Duration(milliseconds: 500));

                    final success = await ref
                        .read(licenseProvider.notifier)
                        .saveLicense(licenseString.value!.trim());

                    if (success) {
                      final newConfig = ref.read(licenseProvider);
                      if (context.mounted) {
                        Navigator.pop(context);
                        onSuccess(newConfig);
                      }
                    } else {
                      if (context.mounted) {
                        context.showErrorSnackBar(
                          'Invalid or corrupted license file.',
                        );
                      }
                    }
                  } finally {
                    isVerifying.value = false;
                  }
                },
          child: Text(isVerifying.value ? 'Verifying...' : 'Activate License'),
        ),
      ],
    );
  }
}
