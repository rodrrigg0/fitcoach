import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:fitcoach/data/models/chat_message.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/services/ai_service.dart';
import 'package:fitcoach/data/services/firestore_service.dart';
import 'package:fitcoach/core/utils/preferences_helper.dart';

class OnboardingProvider extends ChangeNotifier {
  final AIService _aiService = AIService();

  List<ChatMessage> _mensajes = [];
  UserProfile _perfilEnConstruccion = UserProfile.vacio();
  bool _estaCargando = false;
  bool _onboardingCompletado = false;

  List<String> _opcionesActuales = [];
  Set<String> _partesIluminadas = {};
  Map<String, String> _statsVisibles = {
    'nombre': '...',
    'objetivo': '...',
    'deporte': '...',
    'dias': '...',
    'peso': '...',
  };

  List<ChatMessage> get mensajes => List.unmodifiable(_mensajes);
  UserProfile get perfilEnConstruccion => _perfilEnConstruccion;
  bool get estaCargando => _estaCargando;
  bool get onboardingCompletado => _onboardingCompletado;
  List<String> get opcionesActuales => List.unmodifiable(_opcionesActuales);
  Set<String> get partesIluminadas => Set.unmodifiable(_partesIluminadas);
  Map<String, String> get statsVisibles => Map.unmodifiable(_statsVisibles);

  String get systemPromptOnboarding => '''
Eres el asistente de bienvenida de FitCoach, una app de entrenamiento y nutrición personalizada para cualquier deporte.

Tu misión es recopilar información del usuario de forma conversacional, amigable y natural, como si fuera una conversación con un entrenador personal.

Debes recopilar TODA esta información en orden natural:
1. Nombre
2. Edad y sexo biológico
3. Peso y altura actuales
4. Objetivo principal (perder grasa, ganar músculo, recomposición, mejorar rendimiento, mantener, salud general)
5. Deportes que practica o quiere practicar (puede ser cualquier deporte, no solo gimnasio)
6. Días disponibles por semana y minutos por sesión
7. Dónde entrena (gimnasio, casa, exterior, mixto)
8. Lesiones o limitaciones físicas
9. Tipo de dieta y alergias alimentarias
10. Presupuesto semanal aproximado en alimentación (en euros)
11. Horas de sueño habituales
12. Suplementos que toma actualmente

Reglas importantes:
- Haz UNA o DOS preguntas por mensaje máximo
- Sé cercano, motivador y usa el nombre del usuario cuando ya lo sepas
- Acepta cualquier deporte: fútbol, natación, ciclismo, artes marciales, yoga, running, padel, tenis, etc.
- Si el usuario da información incompleta, pide aclaración de forma natural
- Cuando tengas TODA la información, responde con un JSON válido con esta estructura exacta y nada más:
PERFIL_COMPLETO:{"nombre":"...","edad":0,"sexo":"...","peso":0.0,"altura":0.0,"objetivo":"...","nivelActividad":"...","deportes":[],"diasEntrenamiento":0,"minutosSesion":0,"lugarEntrenamiento":"...","lesiones":"...","tipoDieta":"...","alergias":[],"presupuestoSemanal":0,"horasSueno":0,"suplementosActuales":[]}
- Antes del JSON muestra un mensaje de cierre motivador

SISTEMA DE OPCIONES RÁPIDAS:
Cuando hagas una pregunta con opciones cerradas, añade al FINAL de tu mensaje esta etiqueta exacta (sin espacios antes del corchete):
OPCIONES:[opcion1|opcion2|opcion3|opcion4]

Usa OPCIONES: obligatoriamente para estas preguntas:
- Objetivo principal: OPCIONES:[Perder grasa|Ganar músculo|Recomposición|Rendimiento|Mantener|Salud general]
- Días disponibles: OPCIONES:[2 días|3 días|4 días|5 días|6 días|7 días]
- Tiempo por sesión: OPCIONES:[30 min|45 min|60 min|90 min]
- Lugar de entrenamiento: OPCIONES:[Gimnasio|Casa|Exterior|Mixto]
- Tipo de dieta: OPCIONES:[Omnívoro|Vegetariano|Vegano|Sin gluten|Keto|Otro]
- Nivel de actividad actual: OPCIONES:[Sedentario|Ligero|Moderado|Activo|Muy activo]
- Horas de sueño: OPCIONES:[5h o menos|6 horas|7 horas|8 horas|9h o más]

Para preguntas abiertas (nombre, peso, altura, deportes específicos, lesiones, alergias, suplementos, presupuesto) NO uses OPCIONES:.
''';

  void iniciarOnboarding() {
    _mensajes = [];
    _perfilEnConstruccion = UserProfile.vacio();
    _onboardingCompletado = false;
    _opcionesActuales = [];
    _partesIluminadas = {};
    _statsVisibles = {
      'nombre': '...',
      'objetivo': '...',
      'deporte': '...',
      'dias': '...',
      'peso': '...',
    };
    _mensajes.add(
      ChatMessage.deIA(
        '¡Hola! Soy tu asistente personal de FitCoach 👋\n'
        'Voy a hacerte unas preguntas para crear tu perfil '
        'completamente personalizado. ¿Cómo te llamas?',
      ),
    );
    notifyListeners();
  }

  Future<void> enviarMensaje(String texto) async {
    if (texto.trim().isEmpty || _estaCargando) return;

    final textoLimpio = texto.trim();
    final mensajeIndex = _mensajes.where((m) => m.esUsuario).length;

    _mensajes.add(ChatMessage.deUsuario(textoLimpio));
    _analizarMensajeUsuario(textoLimpio, mensajeIndex);
    notifyListeners();

    final mensajeCargando = ChatMessage.cargando();
    _mensajes.add(mensajeCargando);
    _estaCargando = true;
    _opcionesActuales = [];
    notifyListeners();

    try {
      final historialSinCargando =
          _mensajes.where((m) => !m.estaCargando).toList();

      final respuestaRaw = await _aiService.enviarMensaje(
        historial: historialSinCargando.sublist(
            0, historialSinCargando.length - 1),
        mensajeUsuario: textoLimpio,
        systemPrompt: systemPromptOnboarding,
      );

      // Mejora 1: extraer OPCIONES:[...] y limpiar el texto
      final parsed = _extraerOpciones(respuestaRaw);
      final textoMostrar = parsed.texto;
      _opcionesActuales = parsed.opciones;

      final idxCargando =
          _mensajes.indexWhere((m) => m.id == mensajeCargando.id);
      if (idxCargando != -1) {
        _mensajes[idxCargando] = ChatMessage.deIA(textoMostrar);
      }

      if (textoMostrar.contains('PERFIL_COMPLETO:')) {
        await _parsearPerfil(textoMostrar);
      }
    } catch (e) {
      final idxCargando =
          _mensajes.indexWhere((m) => m.id == mensajeCargando.id);
      if (idxCargando != -1) {
        _mensajes[idxCargando] = ChatMessage.deIA(
            'Lo siento, ocurrió un error. Por favor intenta de nuevo.');
      }
      _opcionesActuales = [];
      rethrow;
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  // ── Mejora 1: parseo de OPCIONES:[...] ──────────────────────

  static ({String texto, List<String> opciones}) _extraerOpciones(
      String respuesta) {
    final match =
        RegExp(r'\s*OPCIONES:\[([^\]]+)\]').firstMatch(respuesta);
    if (match == null) return (texto: respuesta.trim(), opciones: []);

    final raw = match.group(1)!;
    final opciones = raw
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final texto =
        respuesta.replaceAll(RegExp(r'\s*OPCIONES:\[[^\]]+\]'), '').trim();
    return (texto: texto, opciones: opciones);
  }

  // ── Análisis del mensaje del usuario ────────────────────────

  void _analizarMensajeUsuario(String texto, int mensajeIndex) {
    final t = texto.toLowerCase().trim();
    bool changed = false;

    // Nombre: primera respuesta, 1-3 palabras, sin dígitos
    if (mensajeIndex == 0 && !RegExp(r'\d').hasMatch(texto)) {
      final palabras = texto
          .trim()
          .split(RegExp(r'\s+'))
          .where((p) => p.isNotEmpty)
          .toList();
      if (palabras.isNotEmpty && palabras.length <= 3) {
        final nombre = palabras
            .map((p) =>
                p[0].toUpperCase() + p.substring(1).toLowerCase())
            .join(' ');
        if (_statsVisibles['nombre'] != nombre) {
          _statsVisibles['nombre'] = nombre;
          changed = true;
        }
      }
    }

    // Peso: número + kg/kilo
    final pesoMatch =
        RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:kg|kilo)', caseSensitive: false)
            .firstMatch(t);
    if (pesoMatch != null) {
      final raw = pesoMatch.group(1)!.replaceAll(',', '.');
      final val = double.tryParse(raw);
      if (val != null && val >= 30 && val <= 300) {
        final str = '${val.toStringAsFixed(1)} kg';
        if (_statsVisibles['peso'] != str) {
          _statsVisibles['peso'] = str;
          changed = true;
        }
      }
    }

    // Días: número + día/días
    final diasMatch =
        RegExp(r'(\d)\s*día', caseSensitive: false).firstMatch(t);
    if (diasMatch != null) {
      final val = int.tryParse(diasMatch.group(1)!);
      if (val != null && val >= 1 && val <= 7) {
        final str = '$val días/sem';
        if (_statsVisibles['dias'] != str) {
          _statsVisibles['dias'] = str;
          changed = true;
        }
      }
    }

    // Objetivo
    final objetivo = _detectarObjetivo(t);
    if (objetivo != null && _statsVisibles['objetivo'] != objetivo) {
      _statsVisibles['objetivo'] = objetivo;
      changed = true;
    }

    // Deporte
    final deporte = _detectarDeporte(t);
    if (deporte != null && _statsVisibles['deporte'] != deporte) {
      _statsVisibles['deporte'] = deporte;
      changed = true;
    }

    // Partes iluminadas
    final nuevasPartes = _detectarPartesIluminadas(t);
    if (nuevasPartes.isNotEmpty) {
      final antes = _partesIluminadas.length;
      _partesIluminadas.addAll(nuevasPartes);
      if (_partesIluminadas.isNotEmpty &&
          _partesIluminadas.length != antes) {
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  static String? _detectarObjetivo(String t) {
    if (t.contains('perder') || t.contains('adelgazar') ||
        t.contains('bajar') || t.contains('grasa') ||
        t.contains('quemar')) {
      return 'Perder grasa';
    }
    if (t.contains('ganar') || t.contains('volumen') ||
        t.contains('músculo') || t.contains('musculo') ||
        t.contains('masa')) {
      return 'Ganar músculo';
    }
    if (t.contains('recomposición') || t.contains('recomposicion')) {
      return 'Recomposición';
    }
    if (t.contains('rendimiento') || t.contains('competir') ||
        t.contains('resistencia')) {
      return 'Rendimiento';
    }
    if (t.contains('mantener') || t.contains('definir') ||
        t.contains('tonificar')) {
      return 'Mantener';
    }
    if (t.contains('salud') || t.contains('bienestar') ||
        t.contains('saludable')) {
      return 'Salud general';
    }
    return null;
  }

  static String? _detectarDeporte(String t) {
    const tabla = [
      (['gym', 'gimnasio', 'pesas', 'musculación', 'musculacion'], 'Gimnasio'),
      (['running', 'correr', 'carrera', 'atletismo'], 'Running'),
      (['fútbol', 'futbol'], 'Fútbol'),
      (['natación', 'natacion', 'nadar'], 'Natación'),
      (['ciclismo', 'bicicleta', 'bike'], 'Ciclismo'),
      (['yoga'], 'Yoga'),
      (['pilates'], 'Pilates'),
      (['pádel', 'padel'], 'Pádel'),
      (['tenis'], 'Tenis'),
      (['basket', 'baloncesto'], 'Baloncesto'),
      (['boxeo'], 'Boxeo'),
      (['crossfit'], 'CrossFit'),
      (['calistenia', 'calisthenics'], 'Calistenia'),
      (['senderismo', 'hiking', 'trekking'], 'Senderismo'),
      (['baile', 'danza'], 'Danza'),
      (['surf'], 'Surf'),
      (['escalada', 'climbing'], 'Escalada'),
      (['voleibol', 'volleyball'], 'Voleibol'),
      (['artes marciales', 'judo', 'karate', 'bjj'], 'Artes marciales'),
      (['esquí', 'esqui'], 'Esquí'),
      (['remo', 'kayak'], 'Remo/Kayak'),
    ];
    for (final (keywords, nombre) in tabla) {
      for (final kw in keywords) {
        if (t.contains(kw)) return nombre;
      }
    }
    return null;
  }

  static Set<String> _detectarPartesIluminadas(String t) {
    final partes = <String>{};
    const brazosYTorso = [
      'gym', 'gimnasio', 'pesas', 'musculacion', 'musculación',
      'crossfit', 'calistenia', 'boxeo', 'artes marciales',
      'judo', 'karate', 'bjj', 'muscu',
    ];
    for (final kw in brazosYTorso) {
      if (t.contains(kw)) {
        partes.addAll(['brazos', 'torso']);
        break;
      }
    }
    const torsoYPiernas = ['yoga', 'pilates', 'estiramientos', 'danza', 'baile'];
    for (final kw in torsoYPiernas) {
      if (t.contains(kw)) {
        partes.addAll(['torso', 'piernas']);
        break;
      }
    }
    const piernas = [
      'running', 'correr', 'atletismo', 'fútbol', 'futbol',
      'basket', 'baloncesto', 'tenis', 'pádel', 'padel',
      'ciclismo', 'bicicleta', 'hiking', 'senderismo',
      'esqui', 'esquí', 'skate', 'voleibol', 'cardio',
    ];
    for (final kw in piernas) {
      if (t.contains(kw)) {
        partes.add('piernas');
        break;
      }
    }
    const completo = [
      'natación', 'natacion', 'nadar', 'surf', 'remo', 'kayak',
      'todo', 'completo', 'fullbody', 'full body', 'funcional',
    ];
    for (final kw in completo) {
      if (t.contains(kw)) {
        partes.addAll(['brazos', 'torso', 'piernas']);
        break;
      }
    }
    return partes;
  }

  // ── Parsear perfil completo ──────────────────────────────────

  Future<void> _parsearPerfil(String respuesta) async {
    try {
      final idx = respuesta.indexOf('PERFIL_COMPLETO:');
      final jsonStr =
          respuesta.substring(idx + 'PERFIL_COMPLETO:'.length).trim();
      final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
      _perfilEnConstruccion = UserProfile.fromJson(jsonData).copyWith(
        id: const Uuid().v4(),
        onboardingCompletado: true,
        fechaRegistro: DateTime.now(),
      );
      await PreferencesHelper.guardarPerfil(_perfilEnConstruccion);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirestoreService().guardarPerfil(_perfilEnConstruccion, uid);
      }
      _onboardingCompletado = true;
    } catch (_) {
      // JSON inválido — continuamos la conversación
    }
  }
}
