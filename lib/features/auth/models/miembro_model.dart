import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/firebase_collections.dart';

class MiembroModel {
  final String uid;
  final String nombreCompleto;
  final String correo;
  final String telefono;
  final String rol;
  final String codigoSobre;
  final DateTime fechaMembresia;
  final bool activo;
  final String direccion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MiembroModel({
    required this.uid,
    required this.nombreCompleto,
    required this.correo,
    required this.telefono,
    required this.rol,
    required this.codigoSobre,
    required this.fechaMembresia,
    required this.activo,
    required this.direccion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MiembroModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MiembroModel(
      uid:             doc.id,
      nombreCompleto:  data[FirebaseCollections.nombreCompleto] ?? '',
      correo:          data[FirebaseCollections.correo]         ?? '',
      telefono:        data[FirebaseCollections.telefono]       ?? '',
      rol:             data[FirebaseCollections.rol]            ?? AppConstants.rolMiembro,
      codigoSobre:     data[FirebaseCollections.codigoSobre]    ?? '',
      fechaMembresia:  (data[FirebaseCollections.fechaMembresia] as Timestamp?)?.toDate() ?? DateTime.now(),
      activo:          data[FirebaseCollections.activo]         ?? true,
      direccion:       data[FirebaseCollections.direccion]      ?? '',
      createdAt:       (data[FirebaseCollections.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:       (data[FirebaseCollections.updatedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory MiembroModel.fromMap(Map<String, dynamic> map, String id) {
    return MiembroModel(
      uid:             id,
      nombreCompleto:  map[FirebaseCollections.nombreCompleto] ?? '',
      correo:          map[FirebaseCollections.correo]         ?? '',
      telefono:        map[FirebaseCollections.telefono]       ?? '',
      rol:             map[FirebaseCollections.rol]            ?? AppConstants.rolMiembro,
      codigoSobre:     map[FirebaseCollections.codigoSobre]    ?? '',
      fechaMembresia:  (map[FirebaseCollections.fechaMembresia] as Timestamp?)?.toDate() ?? DateTime.now(),
      activo:          map[FirebaseCollections.activo]         ?? true,
      direccion:       map[FirebaseCollections.direccion]      ?? '',
      createdAt:       (map[FirebaseCollections.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:       (map[FirebaseCollections.updatedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseCollections.nombreCompleto: nombreCompleto,
      FirebaseCollections.correo:         correo,
      FirebaseCollections.telefono:       telefono,
      FirebaseCollections.rol:            rol,
      FirebaseCollections.codigoSobre:    codigoSobre,
      FirebaseCollections.fechaMembresia: Timestamp.fromDate(fechaMembresia),
      FirebaseCollections.activo:         activo,
      FirebaseCollections.direccion:      direccion,
      FirebaseCollections.createdAt:      Timestamp.fromDate(createdAt),
      FirebaseCollections.updatedAt:      Timestamp.fromDate(updatedAt),
    };
  }

  MiembroModel copyWith({
    String?   uid,
    String?   nombreCompleto,
    String?   correo,
    String?   telefono,
    String?   rol,
    String?   codigoSobre,
    DateTime? fechaMembresia,
    bool?     activo,
    String?   direccion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MiembroModel(
      uid:            uid            ?? this.uid,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correo:         correo         ?? this.correo,
      telefono:       telefono       ?? this.telefono,
      rol:            rol            ?? this.rol,
      codigoSobre:    codigoSobre    ?? this.codigoSobre,
      fechaMembresia: fechaMembresia ?? this.fechaMembresia,
      activo:         activo         ?? this.activo,
      direccion:      direccion      ?? this.direccion,
      createdAt:      createdAt      ?? this.createdAt,
      updatedAt:      updatedAt      ?? this.updatedAt,
    );
  }

  String get rolLabel =>
      AppConstants.rolesLabel[rol] ?? rol;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MiembroModel && other.uid == uid);

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'MiembroModel(uid: $uid, nombre: $nombreCompleto, rol: $rol)';
}