// // ═══════════════════════════════════════════════════════════════════════════
// //  lib/core/router/app_router.dart
// //  Navegación con GoRouter + protección de rutas según autenticación y rol
// // ═══════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../../features/auth/services/auth_service.dart';
// import '../../features/auth/screens/login_screen.dart';
// import '../../features/auth/screens/register_screen.dart';
// import '../../features/dashboard/screens/dashboard_screen.dart';
// import '../../features/ingresos/screens/ingreso_form_screen.dart';
// import '../../features/ingresos/screens/historial_ingresos_screen.dart';
// import '../../features/gastos/screens/gasto_form_screen.dart';
// import '../../features/gastos/screens/historial_gastos_screen.dart';
// import '../../features/miembros/screens/miembros_list_screen.dart';
// import '../../features/miembros/screens/miembro_detail_screen.dart';
// import '../../features/reportes/screens/reportes_screen.dart';
// import '../constants/app_routes.dart';
// import '../widgets/main_shell.dart';

// part 'app_router.g.dart';

// // ── Provider del router ───────────────────────────────────────────────────────
// @riverpod
// GoRouter appRouter(AppRouterRef ref) {
//   final authState = ref.watch(authStateProvider);

//   return GoRouter(
//     initialLocation: AppRoutes.login,
//     debugLogDiagnostics: true,

//     // ── Redirección según autenticación ─────────────────────────────────────
//     redirect: (context, state) {
//       final isLoggedIn = authState.valueOrNull != null;
//       final isPublicRoute = state.matchedLocation == AppRoutes.login ||
//           state.matchedLocation == AppRoutes.register;

//       // Si no está autenticado y va a ruta protegida → login
//       if (!isLoggedIn && !isPublicRoute) return AppRoutes.login;

//       // Si está autenticado y va a login/register → dashboard
//       if (isLoggedIn && isPublicRoute) return AppRoutes.dashboard;

//       return null; // sin redirección
//     },

//     routes: [
//       // ── Rutas públicas ─────────────────────────────────────────────────────
//       GoRoute(
//         path: AppRoutes.login,
//         name: 'login',
//         builder: (context, state) => const LoginScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.register,
//         name: 'register',
//         builder: (context, state) => const RegisterScreen(),
//       ),

//       // ── Shell con BottomNavigationBar ───────────────────────────────────
//       ShellRoute(
//         builder: (context, state, child) => MainShell(child: child),
//         routes: [
//           GoRoute(
//             path: AppRoutes.dashboard,
//             name: 'dashboard',
//             builder: (context, state) => const DashboardScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.ingresos,
//             name: 'ingresos',
//             builder: (context, state) => const HistorialIngresosScreen(),
//             routes: [
//               GoRoute(
//                 path: 'nuevo',
//                 name: 'ingresoNuevo',
//                 builder: (context, state) => const IngresoFormScreen(),
//               ),
//               GoRoute(
//                 path: 'editar/:id',
//                 name: 'ingresoEditar',
//                 builder: (context, state) => IngresoFormScreen(
//                   ingresoId: state.pathParameters['id'],
//                 ),
//               ),
//             ],
//           ),
//           GoRoute(
//             path: AppRoutes.gastos,
//             name: 'gastos',
//             builder: (context, state) => const HistorialGastosScreen(),
//             routes: [
//               GoRoute(
//                 path: 'nuevo',
//                 name: 'gastoNuevo',
//                 builder: (context, state) => const GastoFormScreen(),
//               ),
//               GoRoute(
//                 path: 'editar/:id',
//                 name: 'gastoEditar',
//                 builder: (context, state) => GastoFormScreen(
//                   gastoId: state.pathParameters['id'],
//                 ),
//               ),
//             ],
//           ),
//           GoRoute(
//             path: AppRoutes.miembros,
//             name: 'miembros',
//             builder: (context, state) => const MiembrosListScreen(),
//             routes: [
//               GoRoute(
//                 path: 'nuevo',
//                 name: 'miembroNuevo',
//                 builder: (context, state) => const MiembroDetailScreen(),
//               ),
//               GoRoute(
//                 path: 'detalle/:id',
//                 name: 'miembroDetalle',
//                 builder: (context, state) => MiembroDetailScreen(
//                   miembroId: state.pathParameters['id'],
//                 ),
//               ),
//             ],
//           ),
//           GoRoute(
//             path: AppRoutes.reportes,
//             name: 'reportes',
//             builder: (context, state) => const ReportesScreen(),
//           ),
//         ],
//       ),
//     ],

//     errorBuilder: (context, state) => Scaffold(
//       backgroundColor: const Color(0xFF1A1510),
//       body: Center(
//         child: Text(
//           'Página no encontrada: ${state.error}',
//           style: const TextStyle(color: Colors.white),
//         ),
//       ),
//     ),
//   );
// }
