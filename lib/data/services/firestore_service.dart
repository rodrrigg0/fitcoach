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

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/models/workout_plan.dart';
import 'package:fitcoach/data/models/meal_plan.dart';
import 'package:fitcoach/data/models/chat_message.dart';
import 'package:fitcoach/data/models/exercise_log.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  static const _keyWorkoutPlan = 'workout_plan';
  static const _keyMealPlan = 'meal_plan';

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
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyWorkoutPlan, jsonEncode(plan.toJson()));
    } catch (e) {
      debugPrint('FirestoreService: error guardando workout en prefs: $e');
    }
  }

  Future<WorkoutPlan?> cargarPlanEntrenamiento(String uid) async {
    // Intenta Firestore primero
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('plans')
          .doc('workout')
          .get()
          .timeout(const Duration(seconds: 8));
      if (doc.exists && doc.data() != null) {
        return WorkoutPlan.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('FirestoreService: error cargando workout: $e');
    }
    // Fallback a SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_keyWorkoutPlan);
      if (json != null) {
        return WorkoutPlan.fromJson(jsonDecode(json) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('FirestoreService: error leyendo workout de prefs: $e');
    }
    return null;
  }

  Future<void> guardarPlanNutricion(MealPlan plan, String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('plans')
        .doc('nutrition')
        .set(plan.toJson());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyMealPlan, jsonEncode(plan.toJson()));
    } catch (e) {
      debugPrint('FirestoreService: error guardando nutrition en prefs: $e');
    }
  }

  Future<MealPlan?> cargarPlanNutricion(String uid) async {
    // Intenta Firestore primero
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('plans')
          .doc('nutrition')
          .get()
          .timeout(const Duration(seconds: 8));
      if (doc.exists && doc.data() != null) {
        return MealPlan.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('FirestoreService: error cargando nutrition: $e');
    }
    // Fallback a SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_keyMealPlan);
      if (json != null) {
        return MealPlan.fromJson(jsonDecode(json) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('FirestoreService: error leyendo nutrition de prefs: $e');
    }
    return null;
  }

  // ─── Workout logs ───────────────────────────────────────────

  Future<void> guardarWorkoutLog(String uid, WorkoutLog log) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('workout_logs')
        .doc(log.id)
        .set(log.toJson());
  }

  Future<List<WorkoutLog>> cargarWorkoutLogs(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('workout_logs')
        .orderBy('fecha', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => WorkoutLog.fromJson(doc.data()))
        .toList();
  }

  Future<List<ExerciseLog>> cargarHistorialEjercicio(
      String uid, String nombreEjercicio) async {
    final logs = await cargarWorkoutLogs(uid);
    final resultado = logs
        .expand((log) => log.ejercicios)
        .where((e) =>
            e.ejercicioNombre.toLowerCase() ==
            nombreEjercicio.toLowerCase())
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    return resultado;
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
