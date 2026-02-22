import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'GradeVault',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Version ${AppVersion.version}',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Primary Description Card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About This App',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'GradeVault is a comprehensive offline-first solution for Nigerian schools to manage student records, enter scores across three terms, and generate professional PDF result sheets with automatic grading and ranking.',
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'With provision to manage student records, scores, and class rankings, the app works completely offline with local backup options.',
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Feature Grid
                _buildFeatureGrid(context),
                const SizedBox(height: 16),

                // Privacy Section
                _buildCard(
                  color: Colors.blue[50],
                  borderColor: Colors.blue[100],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.blue[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Privacy & Security',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your school's data is stored locally on your device. We don't collect, transmit, or store any student information on external servers. Optional local backup allows you to export and import data as needed, giving you full control over your information.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Supported Levels Card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Supported School Levels',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLevelGrid(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Footer
                const Text(
                  'Made for Nigerian Schools 🇳🇬',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 16) / 2;
        final bool isMobile = constraints.maxWidth < 600;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildFeatureItem(
              width: isMobile ? constraints.maxWidth : cardWidth,
              icon: Icons.people_outline,
              iconBg: Colors.green[50]!,
              iconColor: Colors.green[600]!,
              title: 'Student Management',
              items: [
                'Add and manage student records',
                'Track student information',
                'Organize by class and session',
              ],
            ),
            _buildFeatureItem(
              width: isMobile ? constraints.maxWidth : cardWidth,
              icon: Icons.description_outlined,
              iconBg: Colors.purple[50]!,
              iconColor: Colors.purple[600]!,
              title: 'Result Generation',
              items: [
                'Professional PDF result sheets',
                'Automatic grading system',
                'Class ranking and positions',
              ],
            ),
            _buildFeatureItem(
              width: isMobile ? constraints.maxWidth : cardWidth,
              icon: Icons.bolt_rounded,
              iconBg: Colors.blue[50]!,
              iconColor: Colors.blue[600]!,
              title: 'Offline First',
              items: [
                'Works without internet',
                'All data stored locally',
                'No server required',
              ],
            ),
            _buildFeatureItem(
              width: isMobile ? constraints.maxWidth : cardWidth,
              icon: Icons.folder_zip_outlined,
              iconBg: Colors.amber[50]!,
              iconColor: Colors.amber[800]!,
              title: 'Data Portability',
              items: [
                'Export data as JSON files',
                'Import backups at any time',
                'Manual data migration',
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required double width,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required List<String> items,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.grey)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLevelColumn('Pre-Nursery', ['PRE-NUR 1', 'PRE-NUR 2']),
        _buildLevelColumn('Nursery', ['NURSERY 1', 'NURSERY 2']),
        _buildLevelColumn('Primary', ['BASIC 1-6']),
        _buildLevelColumn('Secondary', ['JSS 1-3', 'SS 1-3']),
        _buildLevelColumn('Custom', ['Any other', 'Class levels']),
      ],
    );
  }

  Widget _buildLevelColumn(String title, List<String> items) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...items.map(
            (i) => Text(
              i,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, Color? color, Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? Colors.grey[200]!),
      ),
      child: child,
    );
  }
}
