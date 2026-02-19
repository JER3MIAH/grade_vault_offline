import 'package:flutter/material.dart';
import 'package:grade_vault_offline/src/core/navigation/nav.dart';
import 'package:grade_vault_offline/src/features/home/presentation/screens/screens.dart';
import 'package:grade_vault_offline/src/features/splash/splash_screen.dart';
import 'package:grade_vault_offline/src/shared/shared.dart' show buildRoute;

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return buildRoute(const SplashScreen(), settings);
    case AppRoutes.home:
      return buildRoute(const HomeView(), settings);
    case AppRoutes.classView:
      return buildRoute(const ClassView(), settings);
    case AppRoutes.student:
      return buildRoute(const StudentView(), settings);
    case AppRoutes.broadSheet:
      return buildRoute(const BroadSheetView(), settings);
    default:
      return null;
  }
}
