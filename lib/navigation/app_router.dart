import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/route_names.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/documents/presentation/screens/document_list_screen.dart';
import '../features/insights/presentation/screens/statistics_screen.dart';
import '../features/maintenance/presentation/screens/maintenance_list_screen.dart';
import '../features/trip/presentation/screens/trip_list_screen.dart';
import '../features/vehicle/domain/entities/vehicle.dart';
import '../features/vehicle/presentation/screens/add_vehicle_screen.dart';
import '../features/vehicle/presentation/screens/vehicle_list_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/assistant/presentation/screens/assistant_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<AsyncValue<dynamic>>(
    const AsyncData(null),
  );

  ref.listen(authStateProvider, (_, next) {
    authNotifier.value = next;
  });

  ref.onDispose(() => authNotifier.dispose());

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.value;

      if (authState.isLoading) return RouteNames.splash;
      if (authState.hasError) return RouteNames.login;

      final isAuthenticated = authState.valueOrNull != null;
      final isOnAuthRoute = [
        RouteNames.login,
        RouteNames.register,
        RouteNames.splash,
      ].contains(state.matchedLocation);

      if (state.matchedLocation == RouteNames.splash && !isAuthenticated) {
        return RouteNames.login;
      }

      if (!isAuthenticated && !isOnAuthRoute) return RouteNames.login;
      if (isAuthenticated && isOnAuthRoute) return RouteNames.dashboard;

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.addVehicle,
        builder: (_, state) => AddVehicleScreen(
          existingVehicle: state.extra as Vehicle?,
        ),
      ),
      GoRoute(
        path: RouteNames.vehicles,
        builder: (_, __) => const VehicleListScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (_, __) => const ProfileScreen(),
      ),
      // ── AI Assistant ─────────────────────────────────
      GoRoute(
        path: RouteNames.assistant,
        builder: (_, __) => const AssistantScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.trips,
            builder: (_, __) => const TripListScreen(),
          ),
          GoRoute(
            path: RouteNames.maintenance,
            builder: (_, __) => const MaintenanceListScreen(),
          ),
          GoRoute(
            path: RouteNames.documents,
            builder: (_, __) => const DocumentListScreen(),
          ),
          GoRoute(
            path: RouteNames.statistics,
            builder: (_, __) => const StatisticsScreen(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
