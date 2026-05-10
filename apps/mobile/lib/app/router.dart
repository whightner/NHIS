import 'package:flutter/material.dart';
import '../features/home/home_page.dart';
import '../features/auth/login_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../user/user_session.dart';

/// Named route constants. Import this everywhere instead of raw strings.
abstract final class AppRoutes {
  static const home      = '/';
  static const login     = '/login';
  static const dashboard = '/dashboard';
}

/// Central route factory. Registered in [NhisApp].
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _slide(const LoginPage());

      case AppRoutes.dashboard:
        final session = settings.arguments as UserSession;
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
