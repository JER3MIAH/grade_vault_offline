import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/core/navigation/nav.dart';
import 'package:grade_vault_offline/src/features/home/presentation/screens/screens.dart';
import 'package:grade_vault_offline/src/features/onboarding/onboarding_screen.dart';
import 'package:grade_vault_offline/src/features/settings/presentation/screens/about_screen.dart';
import 'package:grade_vault_offline/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:grade_vault_offline/src/features/settings/presentation/screens/school_settings_screen.dart';
import 'package:grade_vault_offline/src/features/settings/presentation/screens/license_details_screen.dart';
import 'package:grade_vault_offline/src/features/splash/splash_screen.dart';
import 'package:toolkit_core/toolkit_core.dart' as tkc;

PageRouteBuilder buildRoute(
  Widget page,
  RouteSettings settings, {
  tkc.TransitionType transition = tkc.TransitionType.fade,
}) {
  return tkc.buildRoute(page, settings, transition: transition);
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return buildRoute(const SplashScreen(), settings);
    case AppRoutes.onboarding:
      return buildRoute(const OnboardingScreen(), settings);
    case AppRoutes.home:
      return buildRoute(const HomeView(), settings);
    case AppRoutes.classView:
      return buildRoute(const ClassView(), settings);
    case AppRoutes.student:
      return buildRoute(const StudentView(), settings);
    case AppRoutes.broadSheet:
      return buildRoute(const BroadSheetView(), settings);
    case AppRoutes.settings:
      return buildRoute(const SettingsScreen(), settings);
    case AppRoutes.schoolSettings:
      return buildRoute(const SchoolSettingsScreen(), settings);
    case AppRoutes.about:
      return buildRoute(const AboutScreen(), settings);
    // case AppRoutes.generateLicense:
    //   return buildRoute(const GenerateLicenseScreen(), settings);
    case AppRoutes.licenseDetails:
      return buildRoute(const LicenseDetailsScreen(), settings);
    default:
      return null;
  }
}
