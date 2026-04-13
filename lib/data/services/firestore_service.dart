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
import 'package:fitcoach/data/models/workout_plan.dart';
import 'package:fitcoach/data/models/meal_plan.dart';
import 'package:fitcoach/data/models/chat_message.dart';

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

  // ─── Planes ─────────────────────────────────────────────────

  Future<void> guardarPlanEntrenamiento(WorkoutPlan plan, String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('plans')
        .doc('workout')
        .set(plan.toJson());
  }

  Future<WorkoutPlan?> cargarPlanEntrenamiento(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('plans')
        .doc('workout')
        .get();
    if (!doc.exists) return null;
    return WorkoutPlan.fromJson(doc.data()!);
  }

  Future<void> guardarPlanNutricion(MealPlan plan, String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('plans')
        .doc('nutrition')
        .set(plan.toJson());
  }

  Future<MealPlan?> cargarPlanNutricion(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('plans')
        .doc('nutrition')
        .get();
    if (!doc.exists) return null;
    return MealPlan.fromJson(doc.data()!);
  }

  // ─── Historial chat ─────────────────────────────────────────

  Future<void> guardarHistorialChat(
      String uid, List<ChatMessage> mensajes) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('chat')
        .doc('history')
        .set({'mensajes': mensajes.map((m) => m.toJson()).toList()});
  }

  Future<List<ChatMessage>> cargarHistorialChat(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('chat')
        .doc('history')
        .get();
    if (!doc.exists) return [];
    final list = doc.data()?['mensajes'] as List<dynamic>? ?? [];
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
