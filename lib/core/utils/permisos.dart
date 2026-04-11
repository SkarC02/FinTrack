import '../../features/auth/models/app_user.dart';

class Permisos {
  Permisos._();

  // ── Dashboard ─────────────────────────────────────
  static bool verDashboard(UserRole rol) =>
      rol != UserRole.miembro;

  // ── Ingresos ──────────────────────────────────────
  static bool verIngresos(UserRole rol) => true;

  static bool registrarIngreso(UserRole rol) =>
      rol == UserRole.admin ||
      rol == UserRole.tesorero ||
      rol == UserRole.secretario;

  static bool editarIngreso(UserRole rol) =>
      rol == UserRole.admin || rol == UserRole.tesorero;

  static bool eliminarIngreso(UserRole rol) =>
      rol == UserRole.admin;

  // ── Gastos ────────────────────────────────────────
  static bool verGastos(UserRole rol) =>
      rol != UserRole.miembro;

  static bool registrarGasto(UserRole rol) =>
      rol == UserRole.admin || rol == UserRole.tesorero;

  static bool editarGasto(UserRole rol) =>
      rol == UserRole.admin || rol == UserRole.tesorero;

  static bool eliminarGasto(UserRole rol) =>
      rol == UserRole.admin;

  // ── Miembros ──────────────────────────────────────
  static bool verMiembros(UserRole rol) =>
      rol != UserRole.miembro;

  static bool gestionarMiembros(UserRole rol) =>
      rol == UserRole.admin || rol == UserRole.tesorero ||
      rol == UserRole.secretario;

  static bool cambiarRol(UserRole rol) =>
      rol == UserRole.admin;

  static bool darDeBaja(UserRole rol) =>
      rol == UserRole.admin || rol == UserRole.tesorero;

  // ── Reportes ──────────────────────────────────────
  static bool verReportes(UserRole rol) =>
      rol != UserRole.miembro;

  static bool exportarReporte(UserRole rol) =>
      rol == UserRole.admin || rol == UserRole.tesorero ||
      rol == UserRole.pastor;
}