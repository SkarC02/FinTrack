import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/firebase_collections.dart';
import '../models/miembro_model.dart';

final miembroServiceProvider = Provider<MiembroService>((ref) {
  return MiembroService(FirebaseFirestore.instance);
});

final miembrosStreamProvider = StreamProvider<List<MiembroModel>>((ref) {
  return ref.watch(miembroServiceProvider).streamMiembros();
});

final miembrosActivosStreamProvider = StreamProvider<List<MiembroModel>>((ref) {
  return ref.watch(miembroServiceProvider).streamMiembrosActivos();
});

final miembroByIdProvider =
    StreamProvider.family<MiembroModel?, String>((ref, uid) {
  return ref.watch(miembroServiceProvider).streamMiembroById(uid);
});

class MiembroFormNotifier extends StateNotifier<AsyncValue<void>> {
  MiembroFormNotifier(this._service) : super(const AsyncValue.data(null));

  final MiembroService _service;

  Future<String?> crearMiembro({
    required String nombreCompleto,
    required String correo,
    required String telefono,
    required String rol,
    required String direccion,
    DateTime? fechaMembresia,
  }) async {
    state = const AsyncValue.loading();
    try {
      final uid = await _service.crearMiembro(
        nombreCompleto: nombreCompleto,
        correo:         correo,
        telefono:       telefono,
        rol:            rol,
        direccion:      direccion,
        fechaMembresia: fechaMembresia ?? DateTime.now(),
      );
      state = const AsyncValue.data(null);
      return uid;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> actualizarMiembro(MiembroModel miembro) async {
    state = const AsyncValue.loading();
    try {
      await _service.actualizarMiembro(miembro);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> toggleActivo(String uid, bool valorActual) async {
    state = const AsyncValue.loading();
    try {
      await _service.toggleActivo(uid, valorActual);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final miembroFormProvider =
    StateNotifierProvider<MiembroFormNotifier, AsyncValue<void>>((ref) {
  return MiembroFormNotifier(ref.watch(miembroServiceProvider));
});

class MiembroService {
  MiembroService(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirebaseCollections.usuarios);

  Stream<List<MiembroModel>> streamMiembros() {
    return _col
        .orderBy(FirebaseCollections.nombreCompleto)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MiembroModel.fromFirestore(d)).toList());
  }

  Stream<List<MiembroModel>> streamMiembrosActivos() {
    return _col
        .where(FirebaseCollections.activo, isEqualTo: true)
        .orderBy(FirebaseCollections.nombreCompleto)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MiembroModel.fromFirestore(d)).toList());
  }

  Stream<MiembroModel?> streamMiembroById(String uid) {
    return _col.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return MiembroModel.fromFirestore(doc);
    });
  }

  Future<String> crearMiembro({
    required String nombreCompleto,
    required String correo,
    required String telefono,
    required String rol,
    required String direccion,
    required DateTime fechaMembresia,
  }) async {
    final now         = DateTime.now();
    final codigoSobre = await _generarCodigoSobre();

    final docRef = _col.doc(); 
    final miembro = MiembroModel(
      uid:            docRef.id,
      nombreCompleto: nombreCompleto,
      correo:         correo,
      telefono:       telefono,
      rol:            rol,
      codigoSobre:    codigoSobre,
      fechaMembresia: fechaMembresia,
      activo:         true,
      direccion:      direccion,
      createdAt:      now,
      updatedAt:      now,
    );

    await docRef.set(miembro.toMap());
    return docRef.id;
  }

  Future<void> actualizarMiembro(MiembroModel miembro) async {
    final updated = miembro.copyWith(updatedAt: DateTime.now());
    await _col.doc(miembro.uid).update(updated.toMap());
  }

  Future<void> toggleActivo(String uid, bool valorActual) async {
    await _col.doc(uid).update({
      FirebaseCollections.activo:    !valorActual,
      FirebaseCollections.updatedAt: Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<String> _generarCodigoSobre() async {
    final snap = await _col
        .orderBy(FirebaseCollections.codigoSobre, descending: true)
        .limit(1)
        .get();

    int siguiente = 1;
    if (snap.docs.isNotEmpty) {
      final ultimo =
          snap.docs.first.data()[FirebaseCollections.codigoSobre] as String? ??
              '';
      final partes = ultimo.split('-');
      if (partes.length == 2) {
        siguiente = (int.tryParse(partes[1]) ?? 0) + 1;
      }
    }

    return '${AppConstants.codigoSobrePrefix}${siguiente.toString().padLeft(4, '0')}';
  }
}