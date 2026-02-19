import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class WrapperContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onAdd;
  const WrapperContainer({
    super.key,
    required this.child,
    required this.title,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: const BoxConstraints(maxHeight: 500, minHeight: 200),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  title,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.start,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
        if (onAdd != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PrimaryButton(title: 'Add +', onTap: onAdd),
          ),
      ],
    );
  }
}
