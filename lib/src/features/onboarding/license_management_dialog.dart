import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/core/constants/app_urls.dart';
import 'package:grade_vault_offline/src/core/navigation/app_routes.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/features/onboarding/paste_license_dialog.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LicenseManagementDialog extends HookConsumerWidget {
  const LicenseManagementDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State for simulated file upload and decryption
    final decryptedDetails = useState<Map<String, dynamic>?>(null);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
          child: const Icon(
            Icons.shield_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'License Management',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Activate your professional school license to unlock full offline capabilities.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
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
          const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF166534),
                  ),
                ),
                Text(
                  "Type: ${details['licenseType']}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
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
        double spacing = 20.0;
        bool isMobile = constraints.maxWidth < 650;

        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _wrapCard(
              isMobile,
              _HoverCard(
                ref: ref,
                title: 'Activate License',
                description:
                    'Already have your license? Upload or paste it here to activate your features immediately.',
                buttonText: 'Activate Now',
                icon: Icons.vpn_key_rounded,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
                hoverBorderColor: Colors.purple.shade300,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => PasteLicenseDialog(
                      onSuccess: (newConfig) async {
                        details.value = {
                          'schoolName': newConfig.name,
                          'licenseType': 'Professional',
                        };
                        await ref
                            .read(appStateProvider.notifier)
                            .updateSchoolInfoFromData(schoolData: newConfig);
                        // ignore: use_build_context_synchronously
                        context.replaceAllNamed(AppRoutes.home);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: isMobile ? 0 : spacing,
              height: isMobile ? spacing : 0,
            ),
            _wrapCard(
              isMobile,
              _HoverCard(
                title: 'Professional License',
                price: '₦105,000',
                badge: 'LIFETIME',
                description:
                    'One-time payment. Get your official school license file and custom branding setup.',
                buttonText: 'Buy Now',
                icon: Icons.workspace_premium_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                hoverBorderColor: Colors.amber.shade400,
                onPressed: () {
                  kLaunchUrlExternalApplication(LICENSE_PURCHASE_URL);
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
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'All data remains on your device. Payments are processed securely via our external partner.',
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
  final String? price;
  final String? badge;
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
    this.price,
    this.badge,
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHovered.value ? hoverBorderColor : Colors.grey.shade100,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered.value
                  ? iconColor.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isHovered.value ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: .end,
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (price != null) ...[
              const SizedBox(height: 4),
              Text(
                price!,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: iconColor,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHovered.value ? iconColor : Colors.white,
                  foregroundColor: isHovered.value ? Colors.white : iconColor,
                  elevation: 0,
                  side: BorderSide(color: iconColor.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
