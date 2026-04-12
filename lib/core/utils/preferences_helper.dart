import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/data/models/user_profile.dart';

class PreferencesHelper {
  PreferencesHelper._();

  static const String _keyUserProfile = 'user_profile';

  static Future<void> guardarPerfil(UserProfile perfil) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyUserProfile, jsonEncode(perfil.toJson()));
  }

  static Future<UserProfile?> cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUserProfile);
    if (json == null) return null;
    return UserProfile.fromJson(
        jsonDecode(json) as Map<String, dynamic>);
  }

  static Future<bool> onboardingCompletado() async {
    final perfil = await cargarPerfil();
    return perfil?.onboardingCompletado ?? false;
  }

  static Future<void> limpiarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
