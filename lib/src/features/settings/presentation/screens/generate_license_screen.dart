import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toolkit_core/toolkit_core.dart' show ContextExtensions;
import 'package:grade_vault_offline/src/core/license/license_manager.dart';
import 'package:flutter/services.dart';

class GenerateLicenseScreen extends HookConsumerWidget {
  const GenerateLicenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController();
    final mottoCtrl = useTextEditingController();
    final addressCtrl = useTextEditingController();
    final branchesCtrl = useTextEditingController();
    final emailCtrl = useTextEditingController();
    final phone1Ctrl = useTextEditingController();
    final phone2Ctrl = useTextEditingController();
    final websiteCtrl = useTextEditingController();
    final establishedYearCtrl = useTextEditingController();

    final generatedLicense = useState<String?>(null);

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
                const SizedBox(height: 8),
                const Text(
                  'Fill in the details to generate an encrypted license string.',
                  style: TextStyle(color: Color(0xFF4B5563)),
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

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    final branches = branchesCtrl.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    final data = {
                      'name': nameCtrl.text,
                      'motto': mottoCtrl.text,
                      'address': addressCtrl.text,
                      'logoPath': null,
                      'branches': branches,
                      'contactInfo': {
                        'email': emailCtrl.text,
                        'phone1': phone1Ctrl.text,
                        'phone2': phone2Ctrl.text,
                      },
                      'website': websiteCtrl.text,
                      'establishedYear': establishedYearCtrl.text,
                      'showFinalPosition': false,

                      'gradingSystem': {
                        'ranges': [
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
                            'teacherRemark':
                                'Great effort! You can reach higher.',
                            'principalRemark':
                                'An excellent performance. Keep it up',
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
                            'principalRemark':
                                'Good result. You can put in more effort.',
                          },
                          {
                            'grade': 'E',
                            'min': 0,
                            'max': 39,
                            'color': '#FF5722',
                            'remark': 'Poor',
                            'teacherRemark': 'Work harder to improve.',
                            'principalRemark':
                                'An average performance. Put in more effort.',
                          },
                        ],
                      },
                    };

                    generatedLicense.value = LicenseManager.encrypt(data);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
}
