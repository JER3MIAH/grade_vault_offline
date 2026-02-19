import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class CustomItemSelector extends HookWidget {
  final String title;
  final List<String> options;

  const CustomItemSelector({
    super.key,
    required this.title,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final selectedOption = useState<String?>(null);
    void selectOption(String value) {
      selectedOption.value = value;
      if (selectedOption.value == null) {
        context.showErrorSnackBar('Please select an option');
        return;
      }
      Navigator.pop(context, selectedOption.value);
    }

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

          if (options.isNotEmpty)
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (_, index) {
                    final option = options[index];
                    return ListTile(
                      title: StyledText(option),
                      onTap: () => selectOption(option),
                    );
                  },
                ),
              ),
            ),

          const YGap(16),
        ],
      ),
    );
  }
}
