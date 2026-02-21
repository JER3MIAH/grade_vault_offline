import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/features/settings/presentation/providers/user_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/core/navigation/nav.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final nav = KitNavigator(context);

    useEffect(() {
      Future.microtask(() async {
        await Future.delayed(const Duration(milliseconds: 3000));

        final currentIsFirstTime = await ref
            .read(userProvider.notifier)
            .checkFirstTime();

        KitLogger.info(
          'SplashScreen: currentIsFirstTime = $currentIsFirstTime',
        );

        nav.replaceAllNamed(
          currentIsFirstTime ? AppRoutes.onboarding : AppRoutes.home,
        );
      });
      return null;
    }, const []);

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(color: KitColors.blue),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(150),
            child: Image.asset('assets/app_icon_no_bg.png'),
          ),
        ),
      ),
    );
  }
}
