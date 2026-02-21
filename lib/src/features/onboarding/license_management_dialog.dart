import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/features/onboarding/paste_license_dialog.dart';
import 'package:toolkit_core/toolkit_core.dart' show ContextExtensions, XGap;
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LicenseManagementDialog extends HookConsumerWidget {
  const LicenseManagementDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State for simulated file upload and decryption
    final decryptedDetails = useState<Map<String, dynamic>?>(null);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.8),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            // Header Section
            _buildHeader(),
            const SizedBox(height: 32),

            // Success Alert (Conditional)
            if (decryptedDetails.value != null)
              _buildSuccessAlert(decryptedDetails.value!),

            const SizedBox(height: 24),

            // Options Grid
            _buildOptionsGrid(ref, decryptedDetails),

            const SizedBox(height: 40),

            // Final Action Button
            if (decryptedDetails.value != null)
              ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to App',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 32),

            // Footer Alert
            _buildInfoAlert(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.key_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 24),
        const Text(
          'Activate Your License',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose an option below to get started with Result Generator App',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Color(0xFF4B5563)),
        ),
      ],
    );
  }

  Widget _buildSuccessAlert(Map<String, dynamic> details) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // green-50
        border: Border.all(color: const Color(0xFFBBF7D0)), // green-200
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF16A34A),
            size: 20,
          ),
          const XGap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'License Activated Successfully!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF166534),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "School: ${details['schoolName']}",
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                "License Type: ${details['licenseType']}",
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(
    WidgetRef ref,
    ValueNotifier<Map<String, dynamic>?> details,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 24.0;
        bool isMobile = constraints.maxWidth < 700;

        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          children: [
            _wrapCard(
              isMobile,
              _HoverCard(
                title: 'Request License',
                description:
                    "Fill out a simple form to receive your school's license file via email within 24 hours",
                buttonText: 'Request Now',
                icon: Icons.open_in_new_rounded,
                iconBg: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF2563EB),
                hoverBorderColor: Colors.blue.shade300,
                onPressed: () {},
              ),
            ),
            SizedBox(
              width: isMobile ? 0 : spacing,
              height: isMobile ? spacing : 0,
            ),
            _wrapCard(
              isMobile,
              _HoverCard(
                ref: ref,
                title: 'Upload License',
                description:
                    "Already have a license file? Upload it here to activate your school's full features",
                buttonText: 'Upload License',
                icon: Icons.upload_file_rounded,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
                hoverBorderColor: Colors.purple.shade300,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => PasteLicenseDialog(
                      onSuccess: (newConfig) {
                        details.value = {
                          'schoolName': newConfig.name,
                          'licenseType': 'Professional',
                        };
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _wrapCard(bool isMobile, Widget child) =>
      isMobile ? child : Expanded(child: child);

  Widget _buildInfoAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF4B5563), size: 20),
          XGap(12),
          Expanded(
            child: Text(
              'Your license file contains your school details. All data is stored locally on your device.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverCard extends HookWidget {
  final WidgetRef? ref;
  final String title;
  final String description;
  final String buttonText;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color hoverBorderColor;
  final VoidCallback onPressed;

  const _HoverCard({
    this.ref,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.hoverBorderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isHovered = useState(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered.value ? hoverBorderColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered.value
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isHovered.value ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(color: Color(0xFF111827)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
