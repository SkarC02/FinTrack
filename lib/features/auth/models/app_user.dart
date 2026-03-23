// ═══════════════════════════════════════════════════════════════════════════
//  lib/features/auth/models/app_user.dart
//  Modelo de usuario de la aplicación
// ═══════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/firebase_collections.dart';

// ── ENUM DE ROLES ─────────────────────────────────────────────────────────────
enum UserRole {
  admin,
  tesorero,
  secretario,
  pastor,
  miembro;

  String get label => AppConstants.rolesLabel[name] ?? name;

  // Permisos por rol
  bool get puedeVerDashboard => this != miembro;
  bool get puedeRegistrarIngresos =>
      this == admin || this == tesorero || this == secretario;
  bool get puedeRegistrarGastos =>
      this == admin || this == tesorero;
  bool get puedeVerGastos =>
      this == admin || this == tesorero || this == pastor;
  bool get puedeGestionarMiembros =>
      this == admin || this == secretario;
  bool get puedeVerReportes =>
      this == admin || this == tesorero || this == pastor;
  bool get puedeGestionarUsuarios => this == admin;
  bool get puedeVerSoloPropios => this == miembro;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.miembro,
    );
  }
}

// ── MODELO APP USER ───────────────────────────────────────────────────────────
class AppUser extends Equatable {
  final String uid;
  final String nombreCompleto;
  final String correo;
  final String telefono;
  final UserRole rol;
  final String codigoSobre;
  final DateTime? fechaMembresia;
  final bool activo;
  final String direccion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.uid,
    required this.nombreCompleto,
    required this.correo,
    this.telefono = '',
    this.rol = UserRole.miembro,
    this.codigoSobre = '',
    this.fechaMembresia,
    this.activo = true,
    this.direccion = '',
    this.createdAt,
    this.updatedAt,
  });

  // ── Iniciales para el avatar ───────────────────────────────────────────────
  String get initials {
    final parts = nombreCompleto.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombreCompleto.isNotEmpty ? nombreCompleto[0].toUpperCase() : '?';
  }

  // ── fromFirestore ──────────────────────────────────────────────────────────
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      nombreCompleto: data[FirebaseCollections.nombreCompleto] ?? '',
      correo: data[FirebaseCollections.correo] ?? '',
      telefono: data[FirebaseCollections.telefono] ?? '',
      rol: UserRole.fromString(data[FirebaseCollections.rol] ?? 'miembro'),
      codigoSobre: data[FirebaseCollections.codigoSobre] ?? '',
      fechaMembresia: (data[FirebaseCollections.fechaMembresia] as Timestamp?)
          ?.toDate(),
      activo: data[FirebaseCollections.activo] ?? true,
      direccion: data[FirebaseCollections.direccion] ?? '',
      createdAt: (data[FirebaseCollections.createdAt] as Timestamp?)?.toDate(),
      updatedAt: (data[FirebaseCollections.updatedAt] as Timestamp?)?.toDate(),
    );
  }

  // ── toFirestore ────────────────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      FirebaseCollections.uId: uid,
      FirebaseCollections.nombreCompleto: nombreCompleto,
      FirebaseCollections.correo: correo,
      FirebaseCollections.telefono: telefono,
      FirebaseCollections.rol: rol.name,
      FirebaseCollections.codigoSobre: codigoSobre,
      FirebaseCollections.fechaMembresia: fechaMembresia != null
          ? Timestamp.fromDate(fechaMembresia!)
          : null,
      FirebaseCollections.activo: activo,
      FirebaseCollections.direccion: direccion,
      FirebaseCollections.createdAt:
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      FirebaseCollections.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  // ── copyWith ───────────────────────────────────────────────────────────────
  AppUser copyWith({
    String? nombreCompleto,
    String? telefono,
    UserRole? rol,
    String? codigoSobre,
    DateTime? fechaMembresia,
    bool? activo,
    String? direccion,
  }) {
    return AppUser(
      uid: uid,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correo: correo,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      codigoSobre: codigoSobre ?? this.codigoSobre,
      fechaMembresia: fechaMembresia ?? this.fechaMembresia,
      activo: activo ?? this.activo,
      direccion: direccion ?? this.direccion,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, nombreCompleto, correo, rol, activo];
}
