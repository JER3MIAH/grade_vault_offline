import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/core/navigation/nav.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/features/settings/presentation/providers/user_notifier.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LicenseManagementScreen extends HookConsumerWidget {
  const LicenseManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final schoolName = useTextEditingController();
    final motto = useTextEditingController();
    final address = useTextEditingController();
    final phone = useTextEditingController();
    final email = useTextEditingController();
    final isSaving = useState(false);

    Future<void> save() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      isSaving.value = true;
      try {
        await ref
            .read(appStateProvider.notifier)
            .updateSchoolInfo(
              name: schoolName.text.trim(),
              motto: motto.text.trim(),
              address: address.text.trim(),
              contactInfo: ContactInfo(
                email: email.text.trim(),
                phone1: phone.text.trim(),
                phone2: '',
              ),
            );
        await ref.read(userProvider.notifier).setFirstTime(false);
        if (context.mounted) context.replaceAllNamed(AppRoutes.home);
      } finally {
        isSaving.value = false;
      }
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFF6FF), Colors.white, Color(0xFFFAF5FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 36),
                      _buildCard(
                        children: [
                          OutlinedTextField(
                            controller: schoolName,
                            labelText: 'School Name *',
                            hintText: 'e.g. Greenfield Academy',
                            height: 50,
                            prefixIcon: const Icon(
                              Icons.school_outlined,
                              size: 20,
                              color: KitColors.neutral500,
                            ),
                            validator: Validators.validateRequiredText,
                          ),
                          const SizedBox(height: 16),
                          OutlinedTextField(
                            controller: motto,
                            labelText: 'School Motto',
                            hintText: 'e.g. Excellence in Learning',
                            height: 50,
                            prefixIcon: const Icon(
                              Icons.format_quote_outlined,
                              size: 20,
                              color: KitColors.neutral500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedTextField(
                            controller: address,
                            labelText: 'Address',
                            hintText: 'e.g. 12 School Road, Lagos',
                            maxLines: 2,
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: KitColors.neutral500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedTextField(
                            controller: phone,
                            labelText: 'Phone Number',
                            hintText: 'e.g. +234 800 000 0000',
                            height: 50,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              size: 20,
                              color: KitColors.neutral500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedTextField(
                            controller: email,
                            labelText: 'Email Address',
                            hintText: 'e.g. info@school.com',
                            height: 50,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 20,
                              color: KitColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSaving.value ? null : save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isSaving.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Start Using GradeVault',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You can update all school details later in Settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
            Icons.school_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Set Up Your School',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your school details to get started.\nAll fields except School Name are optional.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Color(0xFF4B5563)),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
