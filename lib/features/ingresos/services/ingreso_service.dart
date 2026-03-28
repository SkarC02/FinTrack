import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingreso_model.dart';

class IngresoService {
  IngresoService._();
  static final IngresoService instance = IngresoService._();

  final _db = FirebaseFirestore.instance;
  final _collection = 'ingresos';

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection(_collection);

  Future<String> crear(IngresoModel ingreso) async {
    final doc = await _ref.add(ingreso.toFirestore());
    return doc.id;
  }

  Future<IngresoModel?> obtenerPorId(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) return null;
    return IngresoModel.fromFirestore(doc);
  }

  Stream<List<IngresoModel>> streamTodos() {
    return _ref
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(IngresoModel.fromFirestore).toList());
  }

  Stream<List<IngresoModel>> streamPorMes(int anio, int mes) {
    final inicio = DateTime(anio, mes, 1);
    final fin = DateTime(anio, mes + 1, 1);
    return _ref
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('fecha', isLessThan: Timestamp.fromDate(fin))
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(IngresoModel.fromFirestore).toList());
  }

  Stream<List<IngresoModel>> streamPorRango(DateTime desde, DateTime hasta) {
    final fin = DateTime(hasta.year, hasta.month, hasta.day, 23, 59, 59);
    return _ref
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(desde))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fin))
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(IngresoModel.fromFirestore).toList());
  }

  Stream<List<IngresoModel>> streamPorTipo(TipoIngreso tipo) {
    return _ref
        .where('tipo', isEqualTo: tipo.value)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(IngresoModel.fromFirestore).toList());
  }

  Stream<List<IngresoModel>> streamPorMiembro(String memberId) {
    return _ref
        .where('memberId', isEqualTo: memberId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(IngresoModel.fromFirestore).toList());
  }

  Future<List<IngresoModel>> buscarPorNombreMiembro(String nombre) async {
    final snap = await _ref
        .orderBy('memberName')
        .startAt([nombre]).endAt(['$nombre\uf8ff']).get();
    return snap.docs.map(IngresoModel.fromFirestore).toList();
  }

  Future<void> actualizar(IngresoModel ingreso) async {
    await _ref.doc(ingreso.id).update(ingreso.toFirestore());
  }

  Future<void> eliminar(String id) async {
    await _ref.doc(id).delete();
  }

  Future<double> totalPorRango(DateTime desde, DateTime hasta) async {
    final fin = DateTime(hasta.year, hasta.month, hasta.day, 23, 59, 59);
    final snap = await _ref
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(desde))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fin))
        .get();
    return snap.docs.fold<double>(
        0.0, (acc, doc) => acc + (doc.data()['monto'] as num).toDouble());
  }

  Future<Map<TipoIngreso, double>> totalesPorTipoEnMes(
      int anio, int mes) async {
    final inicio = DateTime(anio, mes, 1);
    final fin = DateTime(anio, mes + 1, 1);
    final snap = await _ref
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('fecha', isLessThan: Timestamp.fromDate(fin))
        .get();

    final Map<TipoIngreso, double> totales = {};
    for (final tipo in TipoIngreso.values) {
      totales[tipo] = 0.0;
    }
    for (final doc in snap.docs) {
      final tipo =
          TipoIngresoExtension.fromString(doc.data()['tipo'] ?? 'ofrenda');
      final monto = (doc.data()['monto'] as num).toDouble();
      totales[tipo] = (totales[tipo] ?? 0) + monto;
    }
    return totales;
  }
}
