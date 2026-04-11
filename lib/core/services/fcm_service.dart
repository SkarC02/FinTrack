import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('🔔 Permiso FCM: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _guardarToken();
    }

    _messaging.onTokenRefresh.listen(_actualizarToken);
  }

  Future<void> _guardarToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('❌ FCM: uid es null');
      return;
    }

    final token = await _messaging.getToken();
    debugPrint('🔑 FCM Token: $token');

    if (token == null) {
      debugPrint('❌ FCM: token es null');
      return;
    }

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .update({'fcmToken': token});

    debugPrint('✅ FCM Token guardado correctamente');
  }

  Future<void> _actualizarToken(String token) async {
    debugPrint('🔄 FCM Token actualizado: $token');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .update({'fcmToken': token});
  }

  Future<void> limpiarToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .update({'fcmToken': ''});

    debugPrint('🗑️ FCM Token limpiado');
  }
}