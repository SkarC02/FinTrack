import 'package:cloud_firestore/cloud_firestore.dart';

class GastoModel {
  final String id;
  final double monto;
  final String descripcion;
  final String categoria;
  final String proveedor;
  final DateTime fecha;

  final String metodoPago;
  final String estado;
  final String aprobadoPor;
  final String numeroFactura;
  final String createdBy;

  GastoModel({
    required this.id,
    required this.monto,
    required this.descripcion,
    required this.categoria,
    required this.proveedor,
    required this.fecha,
    required this.metodoPago,
    required this.estado,
    required this.aprobadoPor,
    required this.numeroFactura,
    required this.createdBy,
  });

  factory GastoModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return GastoModel(
        id: doc.id,
        monto: 0,
        descripcion: '',
        categoria: '',
        proveedor: '',
        fecha: DateTime.now(),
        metodoPago: '',
        estado: 'pagado',
        aprobadoPor: '',
        numeroFactura: '',
        createdBy: '',
      );
    }

    return GastoModel(
      id: doc.id,
      monto: (data['monto'] as num?)?.toDouble() ?? 0.0,
      descripcion: data['descripcion'] as String? ?? '',
      categoria: data['categoria'] as String? ?? '',
      proveedor: data['proveedor'] as String? ?? '',
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metodoPago: data['metodoPago'] as String? ?? '',
      estado: data['estado'] as String? ?? 'pagado',
      aprobadoPor: data['aprobadoPor'] as String? ?? '',
      numeroFactura: data['numeroFactura'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'monto': monto,
      'descripcion': descripcion,
      'categoria': categoria,
      'proveedor': proveedor,
      'fecha': Timestamp.fromDate(fecha),
      'metodoPago': metodoPago,
      'estado': estado,
      'aprobadoPor': aprobadoPor,
      'numeroFactura': numeroFactura,
      'createdBy': createdBy,
    };
  }

  GastoModel copyWith({
    String? id,
    double? monto,
    String? descripcion,
    String? categoria,
    String? proveedor,
    DateTime? fecha,
    String? metodoPago,
    String? estado,
    String? aprobadoPor,
    String? numeroFactura,
    String? createdBy,
  }) {
    return GastoModel(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      proveedor: proveedor ?? this.proveedor,
      fecha: fecha ?? this.fecha,
      metodoPago: metodoPago ?? this.metodoPago,
      estado: estado ?? this.estado,
      aprobadoPor: aprobadoPor ?? this.aprobadoPor,
      numeroFactura: numeroFactura ?? this.numeroFactura,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}