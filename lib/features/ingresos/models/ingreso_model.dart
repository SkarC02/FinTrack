// ═══════════════════════════════════════════════════════════════════════════
//  lib/features/ingresos/models/ingreso_model.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoIngreso {
  diezmo,
  ofrenda,
  donacion,
  primicia,
  misiones,
}

extension TipoIngresoExtension on TipoIngreso {
  String get label {
    switch (this) {
      case TipoIngreso.diezmo:
        return 'Diezmo';
      case TipoIngreso.ofrenda:
        return 'Ofrenda';
      case TipoIngreso.donacion:
        return 'Donación';
      case TipoIngreso.primicia:
        return 'Primicia';
      case TipoIngreso.misiones:
        return 'Misiones';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static TipoIngreso fromString(String value) {
    return TipoIngreso.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoIngreso.ofrenda,
    );
  }
}

enum MetodoPago {
  efectivo,
  transferencia,
  cheque,
}

extension MetodoPagoExtension on MetodoPago {
  String get label {
    switch (this) {
      case MetodoPago.efectivo:
        return 'Efectivo';
      case MetodoPago.transferencia:
        return 'Transferencia';
      case MetodoPago.cheque:
        return 'Cheque';
    }
  }

  String get value => toString().split('.').last;

  static MetodoPago fromString(String value) {
    return MetodoPago.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MetodoPago.efectivo,
    );
  }
}

class IngresoModel {
  final String id;
  final TipoIngreso tipo;
  final double monto;
  final String memberId;
  final String memberName;
  final DateTime fecha;
  final MetodoPago metodo;
  final String notas;
  final String registradoPor; // UID del usuario que registró

  const IngresoModel({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.memberId,
    required this.memberName,
    required this.fecha,
    required this.metodo,
    this.notas = '',
    this.registradoPor = '',
  });

  // ── Firestore → Model ────────────────────────────────────────
  factory IngresoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IngresoModel(
      id: doc.id,
      tipo: TipoIngresoExtension.fromString(data['tipo'] ?? 'ofrenda'),
      monto: (data['monto'] as num).toDouble(),
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      metodo: MetodoPagoExtension.fromString(data['metodo'] ?? 'efectivo'),
      notas: data['notas'] ?? '',
      registradoPor: data['registradoPor'] ?? '',
    );
  }

  // ── Model → Firestore ────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'tipo': tipo.value,
      'monto': monto,
      'memberId': memberId,
      'memberName': memberName,
      'fecha': Timestamp.fromDate(fecha),
      'metodo': metodo.value,
      'notas': notas,
      'registradoPor': registradoPor,
      'creadoEn': FieldValue.serverTimestamp(),
    };
  }

  // ── copyWith ─────────────────────────────────────────────────
  IngresoModel copyWith({
    String? id,
    TipoIngreso? tipo,
    double? monto,
    String? memberId,
    String? memberName,
    DateTime? fecha,
    MetodoPago? metodo,
    String? notas,
    String? registradoPor,
  }) {
    return IngresoModel(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      monto: monto ?? this.monto,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      fecha: fecha ?? this.fecha,
      metodo: metodo ?? this.metodo,
      notas: notas ?? this.notas,
      registradoPor: registradoPor ?? this.registradoPor,
    );
  }

  @override
  String toString() =>
      'IngresoModel(id: $id, tipo: ${tipo.label}, monto: $monto, member: $memberName)';
}
