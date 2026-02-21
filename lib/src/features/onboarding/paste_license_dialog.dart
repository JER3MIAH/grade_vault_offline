import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/core/license/license_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toolkit_core/toolkit_core.dart';

class PasteLicenseDialog extends HookConsumerWidget {
  final Function(dynamic) onSuccess;

  const PasteLicenseDialog({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textCtrl = useTextEditingController();
    final isVerifying = useState(false);

    const border = OutlineInputBorder(
      borderSide: BorderSide(color: KitColors.neutral300),
    );

    return AlertDialog(
      title: const Text('Paste License String'),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: textCtrl,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Paste your encrypted license string here...',
            border: border,
            focusedBorder: border,
            disabledBorder: border,
            enabledBorder: border,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isVerifying.value
              ? null
              : () async {
                  final text = textCtrl.text.trim();
                  if (text.isEmpty) {
                    context.showErrorSnackBar('Please enter a license string');
                    return;
                  }

                  isVerifying.value = true;
                  try {
                    await Future.delayed(const Duration(milliseconds: 500));
                    final success = await ref
                        .read(licenseProvider.notifier)
                        .saveLicense(text);

                    if (success) {
                      final newConfig = ref.read(licenseProvider);
                      if (context.mounted) {
                        Navigator.pop(context);
                        onSuccess(newConfig);
                      }
                    } else {
                      if (context.mounted) {
                        context.showErrorSnackBar('Invalid License String.');
                      }
                    }
                  } finally {
                    isVerifying.value = false;
                  }
                },
          child: Text(isVerifying.value ? 'Verifying...' : 'Verify'),
        ),
      ],
    );
  }
}
