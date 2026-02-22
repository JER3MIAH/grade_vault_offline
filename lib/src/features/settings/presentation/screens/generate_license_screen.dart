import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/core/license/license_manager.dart';
import 'package:flutter/services.dart';

const _defaultGradingRanges = [
  {
    'grade': 'A',
    'min': 70,
    'max': 100,
    'color': '#4CAF50',
    'remark': 'Excellent',
    'teacherRemark': 'Outstanding work! Keep it up.',
    'principalRemark':
        'This is an outstanding performance. Keep soaring higher.',
  },
  {
    'grade': 'B',
    'min': 60,
    'max': 69,
    'color': '#8BC34A',
    'remark': 'Very good',
    'teacherRemark': 'Great effort! You can reach higher.',
    'principalRemark': 'An excellent performance. Keep it up',
  },
  {
    'grade': 'C',
    'min': 50,
    'max': 59,
    'color': '#FFC107',
    'remark': 'Good',
    'teacherRemark': 'Good work, focus on weak areas.',
    'principalRemark': 'A very good result. Keep it up',
  },
  {
    'grade': 'D',
    'min': 40,
    'max': 49,
    'color': '#FF9800',
    'remark': 'Fair',
    'teacherRemark': 'Needs more dedication.',
    'principalRemark': 'Good result. You can put in more effort.',
  },
  {
    'grade': 'E',
    'min': 0,
    'max': 39,
    'color': '#FF5722',
    'remark': 'Poor',
    'teacherRemark': 'Work harder to improve.',
    'principalRemark': 'An average performance. Put in more effort.',
  },
];

class GenerateLicenseScreen extends HookConsumerWidget {
  const GenerateLicenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imgPickerHelper = ImageBase64Picker();
    // Text Controllers
    final nameCtrl = useTextEditingController();
    final mottoCtrl = useTextEditingController();
    final addressCtrl = useTextEditingController();
    final branchesCtrl = useTextEditingController();
    final emailCtrl = useTextEditingController();
    final phone1Ctrl = useTextEditingController();
    final phone2Ctrl = useTextEditingController();
    final websiteCtrl = useTextEditingController();
    final establishedYearCtrl = useTextEditingController();

    // States
    final generatedLicense = useState<String?>(null);
    final logoPath = useState<String?>(null); // State for Logo
    final showFinalPosition = useState<bool>(false); // Dynamic Toggle
    final gradingRanges = useState<List<Map<String, dynamic>>>(
      List<Map<String, dynamic>>.from(_defaultGradingRanges),
    );

    // Image Picker Helper
    Future<void> pickLogo() async {
      final path = await imgPickerHelper.pickImageAsBase64();
      if (path != null) {
        logoPath.value = path;
      }
    }

    String? runValidation() {
      final error = ValidationRunner.run([
        ValidationRule(
          () => Validators.validateRequiredText(nameCtrl.text.trim()),
        ),
        ValidationRule(
          () => Validators.validateRequiredText(addressCtrl.text.trim()),
        ),
        ValidationRule(
          () => Validators.validateRequiredText(branchesCtrl.text.trim()),
        ),
        ValidationRule(() => Validators.validateEmail(emailCtrl.text.trim())),
        ValidationRule(
          () => Validators.validatePhoneNumber(
            phone1Ctrl.text.trim(),
            isOptional: false,
          ),
        ),
      ]);
      return error;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Generate License',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: context.pop,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter School Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Logo Upload Section ---
                _buildSectionLabel('School Logo'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: pickLogo,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: logoPath.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              Uint8List.fromList(base64Decode(logoPath.value!)),
                              fit: BoxFit.contain,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.grey.shade400,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Click to upload logo',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                  ),
                ),
                if (logoPath.value != null)
                  TextButton(
                    onPressed: () => logoPath.value = null,
                    child: const Text(
                      'Remove Logo',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),

                _buildTextField('School Name', nameCtrl, Icons.school_outlined),
                const SizedBox(height: 16),
                _buildTextField(
                  'Motto',
                  mottoCtrl,
                  Icons.format_quote_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Address',
                  addressCtrl,
                  Icons.location_on_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Branches (comma separated)',
                  branchesCtrl,
                  Icons.business_outlined,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Email',
                        emailCtrl,
                        Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        'Website',
                        websiteCtrl,
                        Icons.language_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Phone 1',
                        phone1Ctrl,
                        Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        'Phone 2',
                        phone2Ctrl,
                        Icons.phone_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Established Year',
                  establishedYearCtrl,
                  Icons.calendar_today_outlined,
                ),

                const SizedBox(height: 24),
                // --- Show Final Position Toggle ---
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Show Final Position on Results',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Determines if student rankings appear on the final sheet',
                  ),
                  value: showFinalPosition.value,
                  onChanged: (val) => showFinalPosition.value = val,
                  activeThumbColor: KitColors.blue,
                ),

                const SizedBox(height: 24),
                _buildGradingSystemSection(context, gradingRanges),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    final error = runValidation();
                    if (error != null) {
                      context.showErrorSnackBar(error);
                      return;
                    }

                    final branches = branchesCtrl.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    final data = {
                      'name': nameCtrl.text,
                      'motto': mottoCtrl.text,
                      'address': addressCtrl.text,
                      'logoPath': logoPath.value,
                      'branches': branches,
                      'contactInfo': {
                        'email': emailCtrl.text,
                        'phone1': phone1Ctrl.text,
                        'phone2': phone2Ctrl.text,
                      },
                      'website': websiteCtrl.text,
                      'establishedYear': establishedYearCtrl.text,
                      'showFinalPosition': showFinalPosition.value,
                      'gradingSystem': {'ranges': gradingRanges.value},
                    };

                    generatedLicense.value = LicenseManager.encrypt(data);
                  },
                  // ... (Keep button style)
                  child: const Text(
                    'Generate License String',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (generatedLicense.value != null) ...[
                  const SizedBox(height: 32),
                  const Text(
                    'Generated License String',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SelectableText(
                          generatedLicense.value!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: generatedLicense.value!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'License copied to clipboard!',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Copy to Clipboard'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            side: const BorderSide(color: Color(0xFF2563EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    );
  }

  Widget _buildGradingSystemSection(
    BuildContext context,
    ValueNotifier<List<Map<String, dynamic>>> gradingRanges,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Grading System',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                _showEditGradeDialog(context, gradingRanges, null);
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Grade'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: gradingRanges.value.isEmpty
              ? const Text(
                  'No grading ranges defined. Please add at least one.',
                  style: TextStyle(color: Colors.red),
                )
              : Column(
                  children: gradingRanges.value.map((range) {
                    final colorHex = range['color'].toString().replaceAll(
                      '#',
                      'FF',
                    );
                    final colorValue =
                        int.tryParse(colorHex, radix: 16) ?? 0xFF000000;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              range['grade'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${range['min']} - ${range['max']} (${range['remark']})",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              _showEditGradeDialog(
                                context,
                                gradingRanges,
                                Map.from(range),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              final newList = List<Map<String, dynamic>>.from(
                                gradingRanges.value,
                              );
                              newList.removeWhere(
                                (e) => e['grade'] == range['grade'],
                              );
                              gradingRanges.value = newList;
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  void _showEditGradeDialog(
    BuildContext context,
    ValueNotifier<List<Map<String, dynamic>>> gradingRanges,
    Map<String, dynamic>? existingRange,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return _GradeDialogContent(
          existingRange: existingRange,
          onSave: (newRange) {
            final newList = List<Map<String, dynamic>>.from(
              gradingRanges.value,
            );
            final index = newList.indexWhere(
              (e) => e['grade'] == newRange['grade'],
            );
            if (index != -1) {
              newList[index] = newRange;
            } else {
              newList.add(newRange);
            }
            // sort by min score descending
            newList.sort(
              (a, b) => (b['min'] as int).compareTo(a['min'] as int),
            );
            gradingRanges.value = newList;
          },
        );
      },
    );
  }
}

class _GradeDialogContent extends HookWidget {
  final Map<String, dynamic>? existingRange;
  final Function(Map<String, dynamic>) onSave;

  const _GradeDialogContent({this.existingRange, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final gradeCtrl = useTextEditingController(
      text: existingRange?['grade']?.toString() ?? '',
    );
    final minCtrl = useTextEditingController(
      text: existingRange?['min']?.toString() ?? '',
    );
    final maxCtrl = useTextEditingController(
      text: existingRange?['max']?.toString() ?? '',
    );
    final selectedColor = useState<String>(
      existingRange?['color']?.toString() ?? '#4CAF50',
    );
    final remarkCtrl = useTextEditingController(
      text: existingRange?['remark']?.toString() ?? '',
    );

    return AlertDialog(
      title: Text(
        existingRange == null ? 'Add Grade Range' : 'Edit Grade Range',
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: gradeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Grade Letter (e.g. A)',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                  LengthLimitingTextInputFormatter(1),
                  _UpperCaseTextFormatter(),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: minCtrl,
                      decoration: const InputDecoration(labelText: 'Min Score'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: maxCtrl,
                      decoration: const InputDecoration(labelText: 'Max Score'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Color',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      '#4CAF50',
                      '#8BC34A',
                      '#FFC107',
                      '#FF9800',
                      '#FF5722',
                      '#F44336',
                      '#E91E63',
                      '#9C27B0',
                      '#673AB7',
                      '#3F51B5',
                      '#2196F3',
                      '#03A9F4',
                      '#00BCD4',
                      '#009688',
                      '#795548',
                    ].map((hex) {
                      final colorValue = int.parse(
                        hex.replaceAll('#', 'FF'),
                        radix: 16,
                      );
                      final isSelected = selectedColor.value == hex;
                      return GestureDetector(
                        onTap: () => selectedColor.value = hex,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: remarkCtrl,
                decoration: const InputDecoration(labelText: 'General Remark'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (gradeCtrl.text.isEmpty ||
                minCtrl.text.isEmpty ||
                maxCtrl.text.isEmpty) {
              return;
            }
            final defaultGrade = _defaultGradingRanges
                .cast<Map<String, dynamic>?>()
                .firstWhere(
                  (r) => r?['grade'] == gradeCtrl.text.toUpperCase(),
                  orElse: () => null,
                );

            onSave({
              'grade': gradeCtrl.text.toUpperCase(),
              'min': int.tryParse(minCtrl.text) ?? 0,
              'max': int.tryParse(maxCtrl.text) ?? 100,
              'color': selectedColor.value,
              'remark': remarkCtrl.text,
              'teacherRemark':
                  existingRange?['teacherRemark'] ??
                  defaultGrade?['teacherRemark'] ??
                  'A good performance.',
              'principalRemark':
                  existingRange?['principalRemark'] ??
                  defaultGrade?['principalRemark'] ??
                  'Keep it up.',
            });
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
