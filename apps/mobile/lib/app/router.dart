import 'package:flutter/material.dart';
import '../features/auth/login_page.dart';
import '../features/auth/registration/registration_page.dart';
import '../features/auth/registration_success_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/home/home_page.dart';
import '../user/session_controller.dart';
import '../user/user_session.dart';

/// Named route constants — import everywhere instead of raw strings.
abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const registrationSuccess = '/register/success';
  static const dashboard = '/dashboard';
}

/// Central route factory — registered in [NhisApp].
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _slide(const LoginPage());

      case AppRoutes.register:
        return _slide(const RegistrationPage());

      case AppRoutes.registrationSuccess:
        return _slide(const RegistrationSuccessPage());

      case AppRoutes.dashboard:
        final session =
            settings.arguments is UserSession
                ? settings.arguments as UserSession
                : SessionController.instance.session;

        if (session == null || !session.isAuthenticated()) {
          return _slide(const LoginPage());
        }

        return _slide(DashboardPage(session: session));

      case AppRoutes.home:
      default:
        return _slide(const HomePage());
    }
  }

  static PageRoute<T> _slide<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 260),
    );
  }
}