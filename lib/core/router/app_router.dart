// ═══════════════════════════════════════════════════════════════════════════
//  lib/core/router/app_router.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/services/auth_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/miembros/screens/miembros_list_screen.dart';
import '../../features/miembros/screens/miembro_detail_screen.dart';
import '../../features/miembros/screens/miembro_nuevo_screen.dart';
import '../constants/app_routes.dart';

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
      if (isLoggedIn && isPublicRoute) return AppRoutes.miembros; // ← temporal: va directo a miembros
      return null;
    },
    routes: [
      // ── Rutas públicas ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Rutas de Miembros (sin ShellRoute por ahora) ────────────────────
      GoRoute(
        path: AppRoutes.miembros,
        builder: (context, state) => const MiembrosListScreen(),
      ),
      GoRoute(
        path: AppRoutes.miembroNuevo,
        builder: (context, state) => const MiembroNuevoScreen(),
      ),
      GoRoute(
        path: AppRoutes.miembroDetalle,          // '/miembros/detalle/:id'
        builder: (context, state) => MiembroDetailScreen(
          miembroId: state.pathParameters['id'] ?? '',
        ),
      ),

      // ── Placeholder dashboard (para que el redirect no falle) ───────────
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const _PlaceholderScreen('Dashboard'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.error}'),
      ),
    ),
  );
});

// ── Pantalla temporal para rutas no implementadas ─────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.nombre);
  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nombre)),
      body: Center(
        child: Text(
          '$nombre\n(en construcción)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}