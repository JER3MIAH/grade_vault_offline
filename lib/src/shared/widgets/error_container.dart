import 'package:flutter/cupertino.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class ErrorContainer extends StatelessWidget {
  final String title;
  final bool show;
  const ErrorContainer({super.key, required this.title, this.show = false});

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: StyledText(
          title,
          color: CupertinoColors.systemRed,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
