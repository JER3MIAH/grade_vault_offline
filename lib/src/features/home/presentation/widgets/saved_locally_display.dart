import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class SavedLocallyDisplay extends StatelessWidget {
  const SavedLocallyDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(color: AppColors.green500),
      child: const Wrap(
        spacing: 8,
        children: [
          Icon(Icons.local_activity, color: Colors.white),
          StyledText(
            'All data saved locally on your device',
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
