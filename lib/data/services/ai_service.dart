import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fitcoach/data/models/chat_message.dart';

class AIService {
  static const String _endpoint =
      'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-opus-4-5';
  static const int _maxTokens = 1024;

  Future<String> enviarMensaje({
    required List<ChatMessage> historial,
    required String mensajeUsuario,
    required String systemPrompt,
  }) async {
    final apiKey = dotenv.env['ANTHROPIC_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
          'API key no encontrada. Verifica el archivo .env');
    }

    final messages = [
      ...historial
          .where((m) => !m.estaCargando)
          .map((m) => {
                'role': m.esUsuario ? 'user' : 'assistant',
                'content': m.contenido,
              }),
      {
        'role': 'user',
        'content': mensajeUsuario,
      },
    ];

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': _maxTokens,
        'system': systemPrompt,
        'messages': messages,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['content'] as List<dynamic>;
      if (content.isEmpty) {
        throw Exception('Respuesta vacía del servidor');
      }
      return (content.first as Map<String, dynamic>)['text'] as String;
    } else {
      final errorData =
          jsonDecode(response.body) as Map<String, dynamic>;
      final errorMsg = errorData['error']?['message'] as String? ??
          'Error desconocido';
      throw Exception(
          'Error ${response.statusCode}: $errorMsg');
    }
  }
}
