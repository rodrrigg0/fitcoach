import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsageTracker {
  static const int maxMensajesChat = 15;
  static const int maxCheckinsHoy = 1;
  static const int maxPlanesEntrenamiento = 2;
  static const int maxPlanesNutricion = 2;

  static String _hoyKey() =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  static Future<int> mensajesHoy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('chat_messages_${_hoyKey()}') ?? 0;
  }

  static Future<bool> puedeEnviarMensaje() async {
    return (await mensajesHoy()) < maxMensajesChat;
  }

  static Future<void> registrarMensaje() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_messages_${_hoyKey()}';
    final actual = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, actual + 1);
  }

  static Future<int> mensajesRestantesHoy() async {
    final usados = await mensajesHoy();
    return (maxMensajesChat - usados).clamp(0, maxMensajesChat);
  }
}
