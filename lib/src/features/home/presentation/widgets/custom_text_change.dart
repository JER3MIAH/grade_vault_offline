import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class CustomTextChange extends HookWidget {
  final String title;

  const CustomTextChange({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const YGap(16),

          OutlinedTextField(controller: controller),
          const YGap(16),
          PrimaryButton(
            title: 'Submit',
            onTap: () {
              final newText = controller.text.trim();

              context.pop(newText.isEmpty ? null : newText);
            },
          ),
        ],
      ),
    );
  }
}
