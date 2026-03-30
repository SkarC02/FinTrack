import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sic_app/features/miembros/screens/miembro_nuevo_screen.dart';

import '../../features/auth/services/auth_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/ingresos/screens/ingreso_form_screen.dart';
import '../../features/ingresos/screens/historial_ingresos_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
// import '../../features/gastos/screens/gasto_form_screen.dart';
// import '../../features/gastos/screens/historial_gastos_screen.dart';
import '../../features/miembros/screens/miembros_list_screen.dart';
import '../../features/miembros/screens/miembro_detail_screen.dart';
// import '../../features/reportes/screens/reportes_screen.dart';
import '../constants/app_routes.dart';
import '../widgets/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isPublicRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isLoggedIn && !isPublicRoute) return AppRoutes.login;
      if (isLoggedIn && isPublicRoute) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [

          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),

          GoRoute(
            path: AppRoutes.ingresos,
            builder: (context, state) => const HistorialIngresosScreen(),
            routes: [
              GoRoute(
                path: 'nuevo',
                builder: (context, state) => const IngresoFormScreen(),
              ),
              GoRoute(
                path: 'editar/:id',
                builder: (context, state) => IngresoFormScreen(
                  ingresoId: state.pathParameters['id'],
                ),
              ),
            ],
          ),

          GoRoute(
            path: AppRoutes.miembros,
            builder: (context, state) => const MiembrosListScreen(),
            routes: [
              GoRoute(
                path: 'nuevo',
                builder: (context, state) => const MiembroNuevoScreen(),
              ),
              GoRoute(
                path: 'detalle/:id',
                builder: (context, state) => MiembroDetailScreen(
                  miembroId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),

          // Gastos 
          // GoRoute(
          //   path: AppRoutes.gastos,
          //   builder: (context, state) => const HistorialGastosScreen(),
          // ),

          // Reportes (pendiente — Fátima)
          // GoRoute(
          //   path: AppRoutes.reportes,
          //   builder: (context, state) => const ReportesScreen(),
          // ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.error}'),
      ),
    ),
  );
});