// ═══════════════════════════════════════════════════════════════════════════
//  lib/core/constants/app_constants.dart
//  Todas las constantes globales de la aplicación SIC
// ═══════════════════════════════════════════════════════════════════════════

class AppConstants {
  AppConstants._();

  // ── Info de la app ────────────────────────────────────────────────────────
  static const String appName      = 'SIC';
  static const String appFullName  = 'Sistema de Contabilidad Iglesia';
  static const String iglesiaNombre = 'Iglesia Central';
  static const String appVersion   = '1.0.0';

  // ── Moneda ────────────────────────────────────────────────────────────────
  static const String simboloMoneda = 'L.';
  static const String codigoMoneda  = 'HNL';

  // ── Código de sobre ───────────────────────────────────────────────────────
  static const String codigoSobrePrefix = 'SIC-';

  // ── Tipos de Ingreso ──────────────────────────────────────────────────────
  static const String tiposDiezmo    = 'diezmo';
  static const String tiposOfrenda   = 'ofrenda';
  static const String tiposDonacion  = 'donacion';
  static const String tiposPrimicia  = 'primicia';
  static const String tiposMisiones  = 'misiones';

  static const List<String> tiposIngreso = [
    tiposDiezmo,
    tiposOfrenda,
    tiposDonacion,
    tiposPrimicia,
    tiposMisiones,
  ];

  static const Map<String, String> tiposIngresoLabel = {
    tiposDiezmo:   'Diezmo',
    tiposOfrenda:  'Ofrenda',
    tiposDonacion: 'Donación',
    tiposPrimicia: 'Primicia',
    tiposMisiones: 'Misiones',
  };

  // ── Categorías de Gasto ───────────────────────────────────────────────────
  static const String catServicios      = 'servicios';
  static const String catMantenimiento  = 'mantenimiento';
  static const String catActividades    = 'actividades';
  static const String catPersonal       = 'personal';
  static const String catMisiones       = 'misiones';

  static const List<String> categoriasGasto = [
    catServicios,
    catMantenimiento,
    catActividades,
    catPersonal,
    catMisiones,
  ];

  static const Map<String, String> categoriasGastoLabel = {
    catServicios:     'Servicios',
    catMantenimiento: 'Mantenimiento',
    catActividades:   'Actividades',
    catPersonal:      'Personal',
    catMisiones:      'Misiones',
  };

  // ── Métodos de Pago ───────────────────────────────────────────────────────
  static const String pagoEfectivo     = 'efectivo';
  static const String pagoTransferencia = 'transferencia';
  static const String pagoCheque       = 'cheque';

  static const List<String> metodosPago = [
    pagoEfectivo,
    pagoTransferencia,
    pagoCheque,
  ];

  static const Map<String, String> metodosPagoLabel = {
    pagoEfectivo:      'Efectivo',
    pagoTransferencia: 'Transferencia',
    pagoCheque:        'Cheque',
  };

  // ── Roles de Usuario ──────────────────────────────────────────────────────
  static const String rolAdmin      = 'admin';
  static const String rolTesorero   = 'tesorero';
  static const String rolSecretario = 'secretario';
  static const String rolPastor     = 'pastor';
  static const String rolMiembro    = 'miembro';

  static const List<String> roles = [
    rolAdmin,
    rolTesorero,
    rolSecretario,
    rolPastor,
    rolMiembro,
  ];

  static const Map<String, String> rolesLabel = {
    rolAdmin:      'Administrador',
    rolTesorero:   'Tesorero',
    rolSecretario: 'Secretario',
    rolPastor:     'Pastor',
    rolMiembro:    'Miembro',
  };

  // ── Validaciones ──────────────────────────────────────────────────────────
  static const int minPasswordLength = 8;
  static const int maxNombreLength   = 100;
  static const int maxNotasLength    = 500;
  static const double montoMinimo    = 0.01;
  static const double montoMaximo    = 9999999.99;
}
