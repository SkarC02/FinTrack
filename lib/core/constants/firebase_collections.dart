// ═══════════════════════════════════════════════════════════════════════════
//  lib/core/constants/firebase_collections.dart
//  Nombres de colecciones Firestore — usar SIEMPRE estas constantes,
//  nunca strings literales en el código.
// ═══════════════════════════════════════════════════════════════════════════

class FirebaseCollections {
  FirebaseCollections._();

  // ── Colecciones raíz ──────────────────────────────────────────────────────
  static const String usuarios        = 'usuarios';
  static const String ingresos        = 'ingresos';
  static const String gastos          = 'gastos';
  static const String cajaChica       = 'caja_chica';
  static const String presupuestos    = 'presupuestos';
  static const String resumenMensual  = 'resumen_mensual';
  static const String proyectos       = 'proyectos';

  // ── Campos del documento Usuario ──────────────────────────────────────────
  static const String uId              = 'uid';
  static const String nombreCompleto   = 'nombreCompleto';
  static const String correo           = 'correo';
  static const String telefono         = 'telefono';
  static const String rol              = 'rol';
  static const String codigoSobre      = 'codigoSobre';
  static const String fechaMembresia   = 'fechaMembresia';
  static const String activo           = 'activo';
  static const String direccion        = 'direccion';
  static const String createdAt        = 'createdAt';
  static const String updatedAt        = 'updatedAt';

  // ── Campos del documento Ingreso ──────────────────────────────────────────
  static const String tipo             = 'tipo';
  static const String monto            = 'monto';
  static const String memberId         = 'memberId';
  static const String memberName       = 'memberName';
  static const String metodoPago       = 'metodoPago';
  static const String recibidoPor      = 'recibidoPor';
  static const String notas            = 'notas';
  static const String fecha            = 'fecha';
  static const String createdBy        = 'createdBy';

  // ── Campos del documento Gasto ────────────────────────────────────────────
  static const String categoria        = 'categoria';
  static const String descripcion      = 'descripcion';
  static const String proveedor        = 'proveedor';
  static const String aprobadoPor      = 'aprobadoPor';
  static const String numeroFactura    = 'numeroFactura';
  static const String estado           = 'estado';

  // ── Campos Resumen Mensual ────────────────────────────────────────────────
  static const String periodo          = 'periodo';
  static const String totalIngresos    = 'totalIngresos';
  static const String totalGastos      = 'totalGastos';
  static const String saldo            = 'saldo';
  static const String ingresosPorTipo  = 'ingresosPorTipo';
  static const String gastosPorCategoria = 'gastosPorCategoria';
}
