import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/core/navigation/nav.dart';
import 'package:toolkit_core/toolkit_core.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Replicating the bg-gradient-to-br from-blue-50 via-white to-purple-50
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    // Header Section
                    _buildHeader(),
                    const YGap(48),

                    // Responsive Grid Section
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 700) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildFeatureCard(
                                  icon: Icons.people_outline,
                                  color: KitColors.green500,
                                  title: 'Student Management',
                                  description:
                                      'Manage student records, add subjects, and track performance across all terms',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFeatureCard(
                                  icon: Icons.description_outlined,
                                  color: Colors.purple,
                                  title: 'PDF Reports',
                                  description:
                                      'Generate professional result sheets with automatic grading and ranking',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFeatureCard(
                                  icon: Icons.trending_up,
                                  color: Colors.blue,
                                  title: 'Offline First',
                                  description:
                                      'Works completely offline with local backup and synchronization',
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Mobile stack
                          return Column(
                            children: [
                              _buildFeatureCard(
                                icon: Icons.people_outline,
                                color: Colors.green,
                                title: 'Student Management',
                                description:
                                    'Manage student records, add subjects, and track performance across all terms',
                              ),
                              const YGap(16),
                              _buildFeatureCard(
                                icon: Icons.description_outlined,
                                color: Colors.purple,
                                title: 'PDF Reports',
                                description:
                                    'Generate professional result sheets with automatic grading and ranking',
                              ),
                              const YGap(16),
                              _buildFeatureCard(
                                icon: Icons.trending_up,
                                color: Colors.blue,
                                title: 'Offline First',
                                description:
                                    'Works completely offline with optional local backup and synchronization',
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    const YGap(48),

                    // Action Button
                    ElevatedButton(
                      onPressed: () {
                        context.pushNamed(AppRoutes.licenseManagement);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), // blue-600
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const YGap(24),

                    // Footer text
                    // const Text(
                    //   'Supports all Nigerian school levels: PRE-NURSERY to SS 1-3',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(color: Colors.grey, fontSize: 14),
                    // ),
                  ],
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.school, size: 48, color: Colors.white),
        ),
        const YGap(24),
        const Text(
          'GradeVault',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827), // gray-900
          ),
        ),
        const YGap(16),
        const Text(
          'Free, open-source result management for schools. Work fully offline, manage students, and generate professional PDF reports.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Color(0xFF4B5563)),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const YGap(16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const YGap(8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
