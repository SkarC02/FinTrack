

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/firebase_collections.dart';

class GastoModel extends Equatable {
  final String id;
  final String categoria;    
  final String descripcion;
  final String proveedor;
  final double monto;
  final String metodoPago;
  final String aprobadoPor;
  final String numeroFactura;
  final String estado;       
  final DateTime fecha;
  final String createdBy;
  final DateTime? createdAt;

  const GastoModel({
    required this.id,
    required this.categoria,
    required this.descripcion,
    this.proveedor = '',
    required this.monto,
    required this.metodoPago,
    this.aprobadoPor = '',
    this.numeroFactura = '',
    this.estado = 'pagado',
    required this.fecha,
    required this.createdBy,
    this.createdAt,
  });

  factory GastoModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return GastoModel(
      id: doc.id,
      categoria: d[FirebaseCollections.categoria] ?? 'servicios',
      descripcion: d[FirebaseCollections.descripcion] ?? '',
      proveedor: d[FirebaseCollections.proveedor] ?? '',
      monto: (d[FirebaseCollections.monto] as num?)?.toDouble() ?? 0.0,
      metodoPago: d[FirebaseCollections.metodoPago] ?? 'efectivo',
      aprobadoPor: d[FirebaseCollections.aprobadoPor] ?? '',
      numeroFactura: d[FirebaseCollections.numeroFactura] ?? '',
      estado: d[FirebaseCollections.estado] ?? 'pagado',
      fecha: (d[FirebaseCollections.fecha] as Timestamp).toDate(),
      createdBy: d[FirebaseCollections.createdBy] ?? '',
      createdAt: (d[FirebaseCollections.createdAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    FirebaseCollections.categoria: categoria,
    FirebaseCollections.descripcion: descripcion,
    FirebaseCollections.proveedor: proveedor,
    FirebaseCollections.monto: monto,
    FirebaseCollections.metodoPago: metodoPago,
    FirebaseCollections.aprobadoPor: aprobadoPor,
    FirebaseCollections.numeroFactura: numeroFactura,
    FirebaseCollections.estado: estado,
    FirebaseCollections.fecha: Timestamp.fromDate(fecha),
    FirebaseCollections.createdBy: createdBy,
    FirebaseCollections.createdAt: FieldValue.serverTimestamp(),
  };

  GastoModel copyWith({
    String? categoria, String? descripcion, String? proveedor,
    double? monto, String? metodoPago, String? aprobadoPor,
    String? numeroFactura, String? estado, DateTime? fecha,
  }) => GastoModel(
    id: id,
    categoria: categoria ?? this.categoria,
    descripcion: descripcion ?? this.descripcion,
    proveedor: proveedor ?? this.proveedor,
    monto: monto ?? this.monto,
    metodoPago: metodoPago ?? this.metodoPago,
    aprobadoPor: aprobadoPor ?? this.aprobadoPor,
    numeroFactura: numeroFactura ?? this.numeroFactura,
    estado: estado ?? this.estado,
    fecha: fecha ?? this.fecha,
    createdBy: createdBy,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, categoria, monto, fecha];
}
