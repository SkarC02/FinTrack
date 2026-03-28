import 'package:cloud_firestore/cloud_firestore.dart';

class GastoModel {
  final String id;
  final double monto;
  final String descripcion;
  final String categoria;
  final String proveedor;
  final DateTime fecha;

  GastoModel({
    required this.id,
    required this.monto,
    required this.descripcion,
    required this.categoria,
    required this.proveedor,
    required this.fecha,
  });

  factory GastoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GastoModel(
      id: doc.id,
      monto: (data['monto'] as num?)?.toDouble() ?? 0,
      descripcion: data['descripcion'] as String? ?? '',
      categoria: data['categoria'] as String? ?? '',
      proveedor: data['proveedor'] as String? ?? '',
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
