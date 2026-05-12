import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';
import 'router.dart';

/// Root widget. Owns [MaterialApp], theme, and route generation.
class NhisApp extends StatelessWidget {
  const NhisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NHIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.warning,
          surface: AppColors.surface,
        ),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.home,
    );
  }
}
