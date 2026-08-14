import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/stitch_theme.dart';
import 'core/widgets/top_app_bar.dart';
import 'core/widgets/side_nav_bar.dart';
import 'core/widgets/bottom_nav_bar.dart';

import 'features/authentication/domain/user_model.dart';
import 'features/authentication/views/login_screen.dart';
import 'features/dashboard/views/windows_operator_dashboard.dart';
import 'features/dashboard/views/android_admin_dashboard.dart';
import 'features/scanning/views/live_scanning_screen.dart';
import 'features/reports/views/area_reports_screen.dart';
import 'features/analytics/views/analytics_reports_screen.dart';
import 'features/upload_queue/views/upload_queue_screen.dart';
import 'features/settings/views/settings_screen.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(const ProviderScope(child: ScanDigitizeApp()));
}

class ScanDigitizeApp extends ConsumerStatefulWidget {
  const ScanDigitizeApp({super.key});

  @override
  ConsumerState<ScanDigitizeApp> createState() => _ScanDigitizeAppState();
}

class _ScanDigitizeAppState extends ConsumerState<ScanDigitizeApp> {
  UserRole? _userRole;

  @override
  Widget build(BuildContext context) {
    if (_userRole == null) {
      return MaterialApp(
        title: 'ScanDigitize',
        debugShowCheckedModeBanner: false,
        theme: StitchTheme.lightTheme,
        home: LoginScreen(
          onLoginSuccess: (role) {
            setState(() => _userRole = role);
          },
        ),
      );
    }

    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return MainScaffold(
              currentRoute: state.uri.path,
              userRole: _userRole!,
              onLogout: () => setState(() => _userRole = null),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 900) {
                      return WindowsOperatorDashboard(
                        onNewBatchPressed: () => context.go('/live_scanning'),
                      );
                    }
                    return AndroidAdminDashboard(
                      onNewBatchPressed: () => context.go('/live_scanning'),
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: '/live_scanning',
              builder: (context, state) => const LiveScanningScreen(),
            ),
            GoRoute(
              path: '/reports',
              builder: (context, state) => const AreaReportsScreen(),
            ),
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsReportsScreen(),
            ),
            GoRoute(
              path: '/upload_queue',
              builder: (context, state) => const UploadQueueScreen(),
            ),
            GoRoute(
              path: '/projects',
              builder: (context, state) => const AreaReportsScreen(),
            ),
            GoRoute(
              path: '/archive',
              builder: (context, state) => const UploadQueueScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'ScanDigitize Enterprise System',
      debugShowCheckedModeBanner: false,
      theme: StitchTheme.lightTheme,
      routerConfig: router,
    );
  }
}

class MainScaffold extends StatelessWidget {
  final String currentRoute;
  final UserRole userRole;
  final VoidCallback onLogout;
  final Widget child;

  const MainScaffold({
    super.key,
    required this.currentRoute,
    required this.userRole,
    required this.onLogout,
    required this.child,
  });

  int _getBottomNavIndex(String route) {
    switch (route) {
      case '/dashboard':
        return 0;
      case '/reports':
        return 1;
      case '/upload_queue':
        return 2;
      case '/settings':
      default:
        return 3;
    }
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/reports');
        break;
      case 2:
        context.go('/upload_queue');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                StitchSideNavBar(
                  currentRoute: currentRoute,
                  onItemSelected: (route) => context.go(route),
                ),
                Expanded(
                  child: Column(
                    children: [
                      StitchTopAppBar(
                        onAccountPressed: onLogout,
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: StitchTopAppBar(
            onAccountPressed: onLogout,
          ),
          body: child,
          bottomNavigationBar: StitchBottomNavBar(
            selectedIndex: _getBottomNavIndex(currentRoute),
            onItemTapped: (index) => _onBottomNavTapped(context, index),
          ),
        );
      },
    );
  }
}
