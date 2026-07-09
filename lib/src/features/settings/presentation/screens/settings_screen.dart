import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/core/navigation/nav.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/features/settings/data/datasources/user_local_datasource.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolInfo = ref.watch(appStateProvider.select((s) => s.schoolInfo));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: context.pop,
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Manage your app preferences',
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                children: [
                  _buildSchoolCard(context, schoolInfo),

                  const SizedBox(height: 24),

                  _buildSettingsItem(
                    icon: Icons.school_outlined,
                    title: 'School Settings',
                    subtitle: 'Edit school info, grading, subjects & more',
                    iconColor: Colors.blue,
                    onTap: () => context.pushNamed(AppRoutes.schoolSettings),
                  ),

                  _buildSettingsItem(
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Learn how we protect your data',
                    iconColor: Colors.purple,
                    onTap: () {
                      kLaunchUrl(PRIVACY_POLICY_URL);
                    },
                  ),

                  _buildSettingsItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App version and information',
                    iconColor: Colors.grey,
                    onTap: () {
                      context.pushNamed(AppRoutes.about);
                    },
                  ),

                  _buildSettingsItem(
                    icon: Icons.favorite_rounded,
                    title: 'Support the Creator',
                    subtitle: 'Keep this app free — show some love',
                    iconColor: Colors.red,
                    onTap: () {
                      kLaunchUrlExternalApplication(
                        'https://selar.com/showlove/jer3miah',
                      );
                    },
                  ),

                  _buildSettingsItem(
                    icon: Icons.mail_outline,
                    title: 'Support',
                    subtitle: 'Get help and contact support',
                    iconColor: Colors.deepOrange,
                    onTap: () {
                      launchEmail(SUPPORT_EMAIL);
                    },
                  ),

                  _buildSettingsItem(
                    icon: Icons.delete_forever_outlined,
                    title: 'Clear App Data',
                    subtitle: 'Erase all grades, settings, and school info',
                    iconColor: Colors.red,
                    onTap: () => _showClearDataConfirmation(context, ref),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'GradeVault Offline\n'
                    'Version ${AppVersion.currentVersion}+${AppVersion.buildNumber}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Clear App Data?'),
          content: const Text(
            'This action will permanently delete all your school configuration, '
            'generated results, and settings. The app will return to '
            'its initial state.\n\nAre you absolutely sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final navigator = KitNavigator(ctx);
                final scaffold = ScaffoldMessenger.of(context);
                final routerContext = context;

                await ref.read(appStateProvider.notifier).clearAllData();
                await ref.read(userLocalDatasourceProvider).clearAllData();

                navigator.popDialog();

                scaffold.showSnackBar(
                  const SnackBar(
                    content: Text('All local app data has been cleared.'),
                    backgroundColor: Colors.green,
                  ),
                );

                if (routerContext.mounted) {
                  context.replaceAllNamed(AppRoutes.onboarding);
                }
              },
              child: const Text('Clear Everything'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSchoolCard(BuildContext context, SchoolInfo details) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF5F3FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.name.isNotEmpty ? details.name : 'No school name set',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: details.name.isNotEmpty
                        ? const Color(0xFF111827)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                if (details.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    details.address,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                if (details.contactInfo.email.isNotEmpty)
                  Text(
                    details.contactInfo.email,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                if (details.contactInfo.phone1.isNotEmpty)
                  Text(
                    details.contactInfo.phone1,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.pushNamed(AppRoutes.schoolSettings),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 12,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Edit School Info',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
