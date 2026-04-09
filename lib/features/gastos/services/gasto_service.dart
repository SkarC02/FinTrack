import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firebase_collections.dart';
import '../../auth/services/auth_service.dart';
import '../models/gasto_model.dart';

final gastoServiceProvider = Provider<GastoService>((ref) {
  return GastoService(uid: ref.watch(authServiceProvider).currentUid ?? '');
});

class GastoService {
  final String uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirebaseCollections.gastos);

  GastoService({required this.uid});

  Future<String> crear(GastoModel gasto) async {
    final data = gasto.toFirestore();
    data[FirebaseCollections.createdBy] = uid;
    final ref = await _col.add(data);
    return ref.id;
  }

  Future<void> actualizar(String id, GastoModel gasto) async {
    await _col.doc(id).update({
      ...gasto.toFirestore(),
      FirebaseCollections.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminar(String id) async => _col.doc(id).delete();

  Future<GastoModel?> obtenerPorId(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? GastoModel.fromFirestore(doc) : null;
  }

  Stream<List<GastoModel>> streamMesActual() {
    final ahora = DateTime.now();
    final inicio = DateTime(ahora.year, ahora.month, 1);
    final fin = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

    return _col
        .where(FirebaseCollections.fecha,
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where(FirebaseCollections.fecha,
            isLessThanOrEqualTo: Timestamp.fromDate(fin))
        .orderBy(FirebaseCollections.fecha, descending: true)
        .snapshots()
        .map((s) => s.docs.map(GastoModel.fromFirestore).toList());
  }

  Stream<List<GastoModel>> streamConFiltros({
    DateTime? desde,
    DateTime? hasta,
    String? categoria,
  }) {
    Query<Map<String, dynamic>> q = _col;
    if (desde != null) {
      q = q.where(FirebaseCollections.fecha,
          isGreaterThanOrEqualTo: Timestamp.fromDate(desde));
    }
    if (hasta != null) {
      q = q.where(FirebaseCollections.fecha,
          isLessThanOrEqualTo: Timestamp.fromDate(hasta));
    }
    if (categoria != null && categoria.isNotEmpty) {
      q = q.where(FirebaseCollections.categoria, isEqualTo: categoria);
    }
    return q
        .orderBy(FirebaseCollections.fecha, descending: true)
        .snapshots()
        .map((s) => s.docs.map(GastoModel.fromFirestore).toList());
  }

  Future<Map<String, double>> totalPorMes(int anio) async {
    final inicio = DateTime(anio, 1, 1);
    final fin = DateTime(anio, 12, 31, 23, 59, 59);
    final snap = await _col
        .where(FirebaseCollections.fecha,
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where(FirebaseCollections.fecha,
            isLessThanOrEqualTo: Timestamp.fromDate(fin))
        .get();

    final result = <String, double>{};
    for (final doc in snap.docs) {
      final g = GastoModel.fromFirestore(doc);
      final key =
          '${g.fecha.year}-${g.fecha.month.toString().padLeft(2, '0')}';
      result[key] = (result[key] ?? 0) + g.monto;
    }
    return result;
  }

  Future<Map<String, double>> totalPorCategoria(
      DateTime desde, DateTime hasta) async {
    final snap = await _col
        .where(FirebaseCollections.fecha,
            isGreaterThanOrEqualTo: Timestamp.fromDate(desde))
        .where(FirebaseCollections.fecha,
            isLessThanOrEqualTo: Timestamp.fromDate(hasta))
        .get();

    final result = <String, double>{};
    for (final doc in snap.docs) {
      final g = GastoModel.fromFirestore(doc);
      result[g.categoria] = (result[g.categoria] ?? 0) + g.monto;
    }
    return result;
  }
}