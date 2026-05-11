import 'package:shared_preferences/shared_preferences.dart';

class TutorialManager {
  static const String _keyTutorialVisto = 'tutorial_home_visto';

  static Future<bool> debesMostrarTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_keyTutorialVisto) ?? false);
  }

  static Future<void> marcarTutorialVisto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorialVisto, true);
  }

  static Future<void> resetearTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTutorialVisto);
  }
}
