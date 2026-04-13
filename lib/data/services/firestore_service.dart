// IMPORTANTE — Reglas de seguridad de Firestore
// Ve a Firebase Console → Firestore → Reglas y pon:
//
// rules_version = '2';
// service cloud.firestore {
//   match /databases/{database}/documents {
//     match /{document=**} {
//       allow read, write: if request.auth != null;
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitcoach/data/models/user_profile.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> guardarPerfil(UserProfile perfil, String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('data')
        .set(perfil.toJson());
    await _firestore.collection('users').doc(uid).update({
      'onboardingCompletado': true,
    });
  }

  Future<UserProfile?> cargarPerfil(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('data')
        .get();
    if (!doc.exists) return null;
    return UserProfile.fromJson(doc.data()!);
  }

  Future<bool> onboardingCompletado(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    return doc.data()?['onboardingCompletado'] as bool? ?? false;
  }

  Future<void> actualizarPerfil(String uid, Map<String, dynamic> datos) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('data')
        .update(datos);
  }
}
