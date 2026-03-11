// IMPORTANTE: Este archivo es generado automáticamente por FlutterFire CLI.
// NO lo escribas a mano. Ejecuta:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// El comando anterior detecta tu proyecto Firebase y genera este archivo.
// Los valores de ejemplo abajo son PLACEHOLDER — reemplaza con los tuyos.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no están configuradas para esta plataforma.',
        );
    }
  }

  // ── ANDROID ──────────────────────────────────────────────────────────────
  // Obtén estos valores en: Firebase Console → Project Settings → Android App
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSy_TU_API_KEY_ANDROID_AQUI',           // <- reemplazar
    appId: '1:123456789:android:abcdef1234567890',        // <- reemplazar
    messagingSenderId: '123456789012',                    // <- reemplazar
    projectId: 'sic-iglesia-app',                        // <- reemplazar
    storageBucket: 'sic-iglesia-app.appspot.com',        // <- reemplazar
  );

  // ── iOS ───────────────────────────────────────────────────────────────────
  // Obtén estos valores en: Firebase Console → Project Settings → iOS App
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSy_TU_API_KEY_IOS_AQUI',               // <- reemplazar
    appId: '1:123456789:ios:abcdef1234567890',            // <- reemplazar
    messagingSenderId: '123456789012',                    // <- reemplazar
    projectId: 'sic-iglesia-app',                        // <- reemplazar
    storageBucket: 'sic-iglesia-app.appspot.com',        // <- reemplazar
    iosBundleId: 'com.iglesia.sic',                      // <- reemplazar
  );

  // ── WEB (opcional) ────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSy_TU_API_KEY_WEB_AQUI',
    appId: '1:123456789:web:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'sic-iglesia-app',
    storageBucket: 'sic-iglesia-app.appspot.com',
    authDomain: 'sic-iglesia-app.firebaseapp.com',
  );
}
