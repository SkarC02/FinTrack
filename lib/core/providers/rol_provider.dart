import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/firebase_collections.dart';
import '../../features/auth/services/auth_service.dart';

final rolActualProvider = StreamProvider<String>((ref) {
  final uid = ref.watch(authServiceProvider).currentUid;
  if (uid == null) return Stream.value('');

  return FirebaseFirestore.instance
      .collection(FirebaseCollections.usuarios)
      .doc(uid)
      .snapshots()
      .map((doc) => doc.data()?[FirebaseCollections.rol] as String? ?? '');
});