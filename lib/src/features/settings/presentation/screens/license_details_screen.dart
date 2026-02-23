import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/core/license/license_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toolkit_core/toolkit_core.dart' show ContextExtensions;

class LicenseDetailsScreen extends HookConsumerWidget {
  const LicenseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolInfo = ref.watch(licenseProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'License Details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
                _buildSectionHeader('Basic Information'),
                _buildInfoCard([
                  _buildDetailRow('School Name', schoolInfo.name),
                  _buildDetailRow('Motto', schoolInfo.motto),
                  _buildDetailRow(
                    'Established Year',
                    schoolInfo.establishedYear.isNotEmpty
                        ? schoolInfo.establishedYear
                        : 'N/A',
                  ),
                  _buildDetailRow('Address', schoolInfo.address),
                  _buildDetailRow('Branches', schoolInfo.branches.join(', ')),
                ]),
                const SizedBox(height: 24),

                _buildSectionHeader('Contact Information'),
                _buildInfoCard([
                  _buildDetailRow(
                    'Email',
                    schoolInfo.contactInfo.email.isNotEmpty
                        ? schoolInfo.contactInfo.email
                        : 'N/A',
                  ),
                  _buildDetailRow(
                    'Phone 1',
                    schoolInfo.contactInfo.phone1.isNotEmpty
                        ? schoolInfo.contactInfo.phone1
                        : 'N/A',
                  ),
                  _buildDetailRow(
                    'Phone 2',
                    schoolInfo.contactInfo.phone2.isNotEmpty
                        ? schoolInfo.contactInfo.phone2
                        : 'N/A',
                  ),
                  _buildDetailRow(
                    'Website',
                    schoolInfo.website.isNotEmpty ? schoolInfo.website : 'N/A',
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionHeader('Grading System'),
                _buildInfoCard(
                  schoolInfo.gradingSystem.ranges.map((range) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _colorFromHex(range.color),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              range.grade,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\${range.min} - \${range.max} (\${range.remark})',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Teacher: \${range.teacherRemark}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                                Text(
                                  'Principal: \${range.principalRemark}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () {
                    // Optionally implement a way to reset to demo from here.
                  },
                  icon: const Icon(
                    Icons.verified_user_outlined,
                    color: Colors.green,
                  ),
                  label: const Text(
                    'License is Valid',
                    style: TextStyle(color: Colors.green),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF\$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
