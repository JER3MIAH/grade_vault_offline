import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/features/settings/data/datasources/user_local_datasource.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SupportPromptDialog extends ConsumerWidget {
  const SupportPromptDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasource = ref.read(userLocalDatasourceProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.red[400],
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Enjoying GradeVault?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'This app is completely free, and keeping it that way takes real effort. '
            'If it\'s made your work easier, a small show of support means the world '
            'and helps keep the app alive.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.favorite_rounded, size: 18),
              label: const Text(
                'Support the Creator',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                context.pop();
                kLaunchUrlExternalApplication(
                  'https://selar.com/showlove/jer3miah',
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => context.pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Maybe Later'),
          ),
          GestureDetector(
            onTap: () async {
              await datasource.setSupportNeverShow(true);
              if (context.mounted) context.pop();
            },
            child: Text(
              "Don't ask again",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                decoration: TextDecoration.underline,
                decorationColor: Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
