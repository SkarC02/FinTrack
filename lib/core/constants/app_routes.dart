// ═══════════════════════════════════════════════════════════════════════════
//  lib/core/constants/app_routes.dart
//  Nombres y paths de rutas — usar SIEMPRE estas constantes
// ═══════════════════════════════════════════════════════════════════════════

class AppRoutes {
  AppRoutes._();

  // ── Rutas públicas (sin autenticación) ────────────────────────────────────
  static const String login    = '/login';
  static const String register = '/register';

  // ── Rutas protegidas (requieren autenticación) ────────────────────────────
  static const String dashboard     = '/dashboard';
  static const String ingresos      = '/ingresos';
  static const String ingresoNuevo  = '/ingresos/nuevo';
  static const String ingresoEditar = '/ingresos/editar/:id';
  static const String gastos        = '/gastos';
  static const String gastoNuevo    = '/gastos/nuevo';
  static const String gastoEditar   = '/gastos/editar/:id';
  static const String miembros      = '/miembros';
  static const String miembroNuevo  = '/miembros/nuevo';
  static const String miembroDetalle = '/miembros/detalle/:id';
  static const String reportes      = '/reportes';
  static const String cajaChica     = '/caja-chica';
  static const String presupuesto   = '/presupuesto';
  static const String proyectos     = '/proyectos';
  static const String perfil        = '/perfil';
}
