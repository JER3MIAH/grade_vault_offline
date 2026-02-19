import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class CustomSearchPicker extends HookWidget {
  final String title;
  final String hintText;
  final List<String> options;
  final String saveButtonText;

  const CustomSearchPicker({
    super.key,
    required this.title,
    required this.options,
    this.hintText = 'Enter value...',
    this.saveButtonText = 'Save',
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final filteredOptions = useState<List<String>>(options);

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

    void selectOption(String value) {
      controller.text = value;
    }

    void save() {
      if (controller.text.isEmpty) {
        context.showErrorSnackBar('Please enter a value');
        return;
      }
      Navigator.pop(context, controller.text.trim());
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
                    return ListTile(
                      title: StyledText(option),
                      onTap: () => selectOption(option),
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
