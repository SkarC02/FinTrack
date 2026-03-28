import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/firebase_collections.dart';
import '../models/app_user.dart';

part 'auth_service.g.dart';

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

@riverpod
Stream<AppUser?> currentUser(CurrentUserRef ref) {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  if (authUser == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection(FirebaseCollections.usuarios)
      .doc(authUser.uid)
      .snapshots()
      .map((snap) => snap.exists ? AppUser.fromFirestore(snap) : null);
}

@riverpod
AuthService authService(AuthServiceRef ref) => AuthService();

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;
      final doc = await _db
          .collection(FirebaseCollections.usuarios)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found-firestore',
          message: 'Usuario no encontrado en la base de datos.',
        );
      }

      final appUser = AppUser.fromFirestore(doc);
      if (!appUser.activo) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'Tu cuenta ha sido desactivada. Contacta al administrador.',
        );
      }

      return appUser;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
    required String nombreCompleto,
    required String telefono,
    required String direccion,
    required UserRole rol,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      final codigoSobre = await _generarCodigoSobre();

      final appUser = AppUser(
        uid: uid,
        nombreCompleto: nombreCompleto.trim(),
        correo: email.trim(),
        telefono: telefono.trim(),
        rol: rol,
        codigoSobre: codigoSobre,
        fechaMembresia: DateTime.now(),
        activo: true,
        direccion: direccion.trim(),
        createdAt: DateTime.now(),
      );

      await _db
          .collection(FirebaseCollections.usuarios)
          .doc(uid)
          .set(appUser.toFirestore());

      await credential.user!.updateDisplayName(nombreCompleto.trim());

      return appUser;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  User? get currentFirebaseUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  Future<String> _generarCodigoSobre() async {
    final snap = await _db
        .collection(FirebaseCollections.usuarios)
        .count()
        .get();

    final numero = (snap.count ?? 0) + 1;
    return '${AppConstants.codigoSobrePrefix}${numero.toString().padLeft(4, '0')}';
  }

  static String errorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'user-disabled':
        return 'Cuenta desactivada. Contacta al administrador.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos.';
      case 'network-request-failed':
        return 'Sin conexión. Verifica tu internet.';
      default:
        return e.message ?? 'Error desconocido.';
    }
  }
}
