import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        centerTitle: false,
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(1),
        //   child: HorizontalLine(),
        // ),
        backgroundColor: colorScheme.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StyledText(
              title,
              fontSize: subtitle.isNotNullOrEmpty ? 20 : 24,
              fontWeight: subtitle.isNotNullOrEmpty
                  ? FontWeight.w500
                  : FontWeight.w700,
              color: KitColors.white,
            ),
            if (subtitle.isNotNullOrEmpty)
              StyledText(
                subtitle!,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: KitColors.white,
              ),
          ],
        ),
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HorizontalLine extends StatelessWidget {
  final bool hasMargin;
  const HorizontalLine({super.key, this.hasMargin = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.inversePrimary,
      margin: hasMargin ? const EdgeInsets.symmetric(vertical: 5) : null,
      height: 1,
    );
  }
}

class VerticalLine extends StatelessWidget {
  final bool hasMargin;
  const VerticalLine({super.key, this.hasMargin = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.inversePrimary,
      margin: hasMargin ? const EdgeInsets.symmetric(vertical: 5) : null,
      width: 1,
    );
  }
}
