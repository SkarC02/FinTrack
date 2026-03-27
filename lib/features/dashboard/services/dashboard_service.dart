// ═══════════════════════════════════════════════════════════════════════════
//  lib/features/dashboard/services/dashboard_service.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firebase_collections.dart';
import '../../ingresos/models/ingreso_model.dart';
import '../../gastos/models/gasto_model.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

class DashboardResumen {
  final double totalIngresos;
  final double totalGastos;
  final double saldo;
  final int totalMiembros;
  final int diezmadores;
  final Map<String, double> ingresosPorTipo;
  final Map<String, double> gastosPorCategoria;
  final List<IngresoModel> ultimasTransaccionesIngreso;
  final List<GastoModel> ultimasTransaccionesGasto;

  DashboardResumen({
    this.totalIngresos = 0,
    this.totalGastos = 0,
    this.saldo = 0,
    this.totalMiembros = 0,
    this.diezmadores = 0,
    this.ingresosPorTipo = const {},
    this.gastosPorCategoria = const {},
    this.ultimasTransaccionesIngreso = const [],
    this.ultimasTransaccionesGasto = const [],
  });
}

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<DashboardResumen> streamResumenMes() {
    final ahora = DateTime.now();
    final inicio = DateTime(ahora.year, ahora.month, 1);
    final fin = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

    // ← Sin orderBy para evitar requerir índice compuesto
    final ingresosStream = _db
        .collection(FirebaseCollections.ingresos)
        .where(FirebaseCollections.fecha,
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where(FirebaseCollections.fecha,
            isLessThanOrEqualTo: Timestamp.fromDate(fin))
        .snapshots();

    return ingresosStream.asyncMap((ingresosSnap) async {
      final ingresos = ingresosSnap.docs
          .map(IngresoModel.fromFirestore)
          .toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha)); // ordenamos en memoria

      double totalIngresos = 0;
      final ingresosPorTipo = <String, double>{};
      for (final i in ingresos) {
        totalIngresos += i.monto;
        ingresosPorTipo[i.tipo.value] =
            (ingresosPorTipo[i.tipo.value] ?? 0) + i.monto;
      }

      // Gastos — sin orderBy también
      final gastosSnap = await _db
          .collection(FirebaseCollections.gastos)
          .where(FirebaseCollections.fecha,
              isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where(FirebaseCollections.fecha,
              isLessThanOrEqualTo: Timestamp.fromDate(fin))
          .get();

      final gastos = gastosSnap.docs.map(GastoModel.fromFirestore).toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha)); // ordenamos en memoria

      double totalGastos = 0;
      final gastosPorCategoria = <String, double>{};
      for (final g in gastos) {
        totalGastos += g.monto;
        gastosPorCategoria[g.categoria] =
            (gastosPorCategoria[g.categoria] ?? 0) + g.monto;
      }

      // Miembros activos
      final miembrosSnap = await _db
          .collection(FirebaseCollections.usuarios)
          .where(FirebaseCollections.activo, isEqualTo: true)
          .count()
          .get();

      // Diezmadores únicos
      final diezmanteIds = ingresos
          .where((i) => i.tipo == TipoIngreso.diezmo)
          .map((i) => i.memberId)
          .toSet()
          .length;

      return DashboardResumen(
        totalIngresos: totalIngresos,
        totalGastos: totalGastos,
        saldo: totalIngresos - totalGastos,
        totalMiembros: miembrosSnap.count ?? 0,
        diezmadores: diezmanteIds,
        ingresosPorTipo: ingresosPorTipo,
        gastosPorCategoria: gastosPorCategoria,
        ultimasTransaccionesIngreso: ingresos.take(5).toList(),
        ultimasTransaccionesGasto: gastos.take(3).toList(),
      );
    });
  }

  Future<List<Map<String, dynamic>>> datosGraficaMensual(
      {int meses = 6}) async {
    final result = <Map<String, dynamic>>[];
    final ahora = DateTime.now();

    for (int i = meses - 1; i >= 0; i--) {
      final mes = DateTime(ahora.year, ahora.month - i, 1);
      final inicio = DateTime(mes.year, mes.month, 1);
      final fin = DateTime(mes.year, mes.month + 1, 0, 23, 59, 59);

      final ingSnap = await _db
          .collection(FirebaseCollections.ingresos)
          .where(FirebaseCollections.fecha,
              isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where(FirebaseCollections.fecha,
              isLessThanOrEqualTo: Timestamp.fromDate(fin))
          .get();

      final gasSnap = await _db
          .collection(FirebaseCollections.gastos)
          .where(FirebaseCollections.fecha,
              isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where(FirebaseCollections.fecha,
              isLessThanOrEqualTo: Timestamp.fromDate(fin))
          .get();

      double totalIng = 0;
      for (final d in ingSnap.docs) {
        totalIng +=
            (d.data()[FirebaseCollections.monto] as num?)?.toDouble() ?? 0;
      }

      double totalGas = 0;
      for (final d in gasSnap.docs) {
        totalGas +=
            (d.data()[FirebaseCollections.monto] as num?)?.toDouble() ?? 0;
      }

      result.add({
        'mes': mes,
        'label': _mesLabel(mes.month),
        'ingresos': totalIng,
        'gastos': totalGas,
      });
    }
    return result;
  }

  String _mesLabel(int month) {
    const meses = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC'
    ];
    return meses[month - 1];
  }
}
