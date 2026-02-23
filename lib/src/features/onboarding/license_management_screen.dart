import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/core/constants/app_urls.dart';
import 'package:grade_vault_offline/src/core/navigation/nav.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/providers.dart';
import 'package:grade_vault_offline/src/features/onboarding/paste_license_dialog.dart';
import 'package:grade_vault_offline/src/features/settings/presentation/providers/user_notifier.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LicenseManagementScreen extends HookConsumerWidget {
  const LicenseManagementScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isProcessing = useState(false);
    final decryptedDetails = useState<Map<String, dynamic>?>(null);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF6FF), // blue-50
              Colors.white,
              Color(0xFFFAF5FF), // purple-50
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 32),

                if (decryptedDetails.value != null)
                  _buildSuccessAlert(decryptedDetails.value!),

                const SizedBox(height: 24),

                _buildOptionsGrid(ref, isProcessing, decryptedDetails, () {
                  ref.read(userProvider.notifier).setFirstTime(false);
                }),

                const SizedBox(height: 40),

                if (decryptedDetails.value != null)
                  ElevatedButton(
                    onPressed: () {
                      ref.read(userProvider.notifier).setFirstTime(false);
                      context.pushNamed(AppRoutes.home);
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
                _buildInfoAlert(),
              ],
            ),
          ),
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
          'Activate GradeVault',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Secure your school data with a professional license',
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
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
          const SizedBox(width: 12),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(
    WidgetRef ref,
    ValueNotifier<bool> isProcessing,
    ValueNotifier<Map<String, dynamic>?> details,
    VoidCallback onUploadSuccess,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 20.0;
        bool isMobile = constraints.maxWidth < 800;

        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _wrapCard(
              isMobile,
              _HoverCard(
                title: 'Activate Key',
                description:
                    'Already have your license key? Paste it here to unlock your school profile.',
                buttonText: isProcessing.value ? 'Processing...' : 'Enter Key',
                icon: Icons.vpn_key_rounded,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
                hoverBorderColor: Colors.purple.shade300,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => PasteLicenseDialog(
                      onSuccess: (newConfig) async {
                        details.value = {'schoolName': newConfig.name};
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
                badge: 'LIFETIME ACCESS',
                description:
                    'Full branding, custom grading, and unlimited student reports. One-time payment.',
                buttonText: 'Buy License',
                icon: Icons.workspace_premium_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                hoverBorderColor: Colors.amber.shade400,
                onPressed: () =>
                    kLaunchUrlExternalApplication(LICENSE_PURCHASE_URL),
              ),
            ),
            SizedBox(
              width: isMobile ? 0 : spacing,
              height: isMobile ? spacing : 0,
            ),
            _wrapCard(
              isMobile,
              _HoverCard(
                title: 'Demo Mode',
                description:
                    'Trial GradeVault with sample data. No payment required to explore features. License can be activated later.',
                buttonText: 'Start Demo',
                icon: Icons.auto_graph_rounded,
                iconBg: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF16A34A),
                hoverBorderColor: Colors.green.shade300,
                onPressed: () {
                  onUploadSuccess();
                  context.replaceAllNamed(AppRoutes.home);
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
              'GradeVault is an offline-first application. Your license and school data are stored securely on this device.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverCard extends HookWidget {
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
        constraints: const BoxConstraints(minHeight: 320),
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
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: .end,
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 9,
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
              const SizedBox(height: 6),
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
                color: Color(0xFF6B7280),
                height: 1.5,
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
                  side: BorderSide(color: iconColor.withValues(alpha: 0.5)),
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
