import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class CustomItemsPicker extends HookWidget {
  final String title;
  final String hintText;
  final List<String> options;
  final String saveButtonText;
  final List<String> impSelectedItems;

  const CustomItemsPicker({
    super.key,
    required this.title,
    required this.options,
    this.hintText = 'Enter value...',
    this.saveButtonText = 'Save',
    this.impSelectedItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final filteredOptions = useState<List<String>>(options);
    final selectedItems = useState<List<String>>(impSelectedItems);

    /// Filter logic reacts automatically to text changes
    useEffect(() {
      controller.addListener(() {
        final text = controller.text.toLowerCase();
        filteredOptions.value = options
            .where((opt) => opt.toLowerCase().contains(text))
            .toList();
      });
      return null;
    }, []);

    void toggleOption(String value) {
      final updated = [...selectedItems.value];
      if (updated.contains(value)) {
        updated.remove(value);
      } else {
        updated.add(value);
      }
      selectedItems.value = updated;
    }

    void save() {
      if (selectedItems.value.isEmpty) {
        context.showErrorSnackBar('Please select at least one value');
        return;
      }
      context.pop(selectedItems.value);
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

          /// Input field
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hintText),
          ),

          const YGap(12),

          /// Filtered options list
          if (filteredOptions.value.isNotEmpty)
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredOptions.value.length,
                  itemBuilder: (context, index) {
                    final option = filteredOptions.value[index];
                    final isSelected = selectedItems.value.contains(option);
                    return CheckboxListTile(
                      checkColor: AppColors.white,
                      title: StyledText(option),
                      value: isSelected,
                      onChanged: (_) => toggleOption(option),
                    );
                  },
                ),
              ),
            ),

          const YGap(16),

          PrimaryButton(onTap: save, title: saveButtonText, expanded: true),
        ],
      ),
    );
  }
}
