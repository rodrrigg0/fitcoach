import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:fitcoach/data/models/chat_message.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/services/ai_service.dart';
import 'package:fitcoach/data/services/firestore_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final AIService _aiService = AIService();

  List<ChatMessage> _mensajes = [];
  UserProfile _perfilEnConstruccion = UserProfile.vacio();
  bool _estaCargando = false;
  bool _onboardingCompletado = false;
  String? _tipoSelectorNumerico;

  List<String> _opcionesActuales = [];
  Set<String> _partesIluminadas = {};
  Map<String, String> _statsVisibles = {
    'nombre': '...',
    'objetivo': '...',
    'deporte': '...',
    'dias': '...',
    'peso': '...',
    'altura': '...',
    'edad': '...',
  };

  List<ChatMessage> get mensajes => List.unmodifiable(_mensajes);
  UserProfile get perfilEnConstruccion => _perfilEnConstruccion;
  bool get estaCargando => _estaCargando;
  bool get onboardingCompletado => _onboardingCompletado;
  List<String> get opcionesActuales => List.unmodifiable(_opcionesActuales);
  Set<String> get partesIluminadas => Set.unmodifiable(_partesIluminadas);
  Map<String, String> get statsVisibles => Map.unmodifiable(_statsVisibles);
  String? get tipoSelectorNumerico => _tipoSelectorNumerico;

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

Para preguntas abiertas (nombre, peso, altura, edad, deportes específicos, lesiones, alergias, suplementos, presupuesto, horas de sueño) NO uses OPCIONES:.
''';

  void iniciarOnboarding() {
    _mensajes = [];
    _perfilEnConstruccion = UserProfile.vacio();
    _onboardingCompletado = false;
    _opcionesActuales = [];
    _partesIluminadas = {};
    _tipoSelectorNumerico = null;
    _statsVisibles = {
      'nombre': '...',
      'objetivo': '...',
      'deporte': '...',
      'dias': '...',
      'peso': '...',
      'altura': '...',
      'edad': '...',
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

  void limpiarSelectorNumerico() {
    _tipoSelectorNumerico = null;
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
    _tipoSelectorNumerico = null;
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
      } else if (_opcionesActuales.isEmpty) {
        _detectarSelectorNumerico(textoMostrar);
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

  // ── Extraer OPCIONES:[...] ───────────────────────────────────

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

  // ── Detectar qué selector numérico mostrar ───────────────────

  void _detectarSelectorNumerico(String mensajeIA) {
    final m = mensajeIA.toLowerCase();
    String? tipo;
    if (m.contains('cuánto pesas') ||
        m.contains('cuanto pesas') ||
        m.contains('tu peso') ||
        (m.contains('peso') && m.contains('kg')) ||
        (m.contains('pesas') && !m.contains('pesas en') && !m.contains('levantas'))) {
      tipo = 'peso';
    } else if (m.contains('altura') ||
        m.contains('cuánto mides') ||
        m.contains('cuanto mides') ||
        m.contains('estatura') ||
        m.contains('talla')) {
      tipo = 'altura';
    } else if (m.contains('cuántos años') ||
        m.contains('cuantos años') ||
        m.contains('tu edad') ||
        (m.contains('edad') && !m.contains('tu edad de')) ||
        (m.contains('años') && m.contains('tienes'))) {
      tipo = 'edad';
    } else if (m.contains('sueño') ||
        m.contains('duermes') ||
        m.contains('dormir') ||
        (m.contains('horas') &&
            !m.contains('semana') &&
            !m.contains('sesión') &&
            !m.contains('sesion') &&
            !m.contains('día') &&
            !m.contains('dia'))) {
      tipo = 'sueno';
    } else if (m.contains('presupuesto') ||
        (m.contains('euros') && m.contains('semana')) ||
        m.contains('cuánto gastas') ||
        m.contains('cuanto gastas') ||
        m.contains('en alimentación') ||
        m.contains('en alimentacion')) {
      tipo = 'presupuesto';
    }
    _tipoSelectorNumerico = tipo;
  }

  // ── Análisis inmediato del mensaje del usuario ───────────────

  void _analizarMensajeUsuario(String texto, int mensajeIndex) {
    final t = texto.toLowerCase().trim();
    final tDot = t.replaceAll(',', '.');
    bool changed = false;

    // Contexto: última pregunta de la IA
    final ultimaIA = _ultimaMensajeIA();

    // ── Nombre ────────────────────────────────────────────────
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

    // ── Peso ──────────────────────────────────────────────────
    {
      double? pesoVal;
      // Explícito: "78 kg", "78kg", "78 kilos", "peso 78"
      final r1 = RegExp(
        r'(?:peso\s+)?(\d+(?:[.,]\d+)?)\s*(?:kg|kilos?)'
        r'|(?:peso|pesa)\s+(\d+(?:[.,]\d+)?)',
        caseSensitive: false,
      ).firstMatch(tDot);
      if (r1 != null) {
        final raw = (r1.group(1) ?? r1.group(2))!;
        final val = double.tryParse(raw);
        if (val != null && val >= 40 && val <= 200) pesoVal = val;
      }
      // Contextual: número solo si la IA preguntó por peso
      if (pesoVal == null && ultimaIA != null) {
        if (ultimaIA.contains('peso') ||
            ultimaIA.contains('pesas') ||
            ultimaIA.contains('kilos') ||
            ultimaIA.contains('kg')) {
          final bare = RegExp(r'^\s*(\d+(?:\.\d+)?)\s*$').firstMatch(tDot);
          if (bare != null) {
            final val = double.tryParse(bare.group(1)!);
            if (val != null && val >= 40 && val <= 200) pesoVal = val;
          }
        }
      }
      if (pesoVal != null) {
        final str = '${pesoVal.toStringAsFixed(1)} kg';
        if (_statsVisibles['peso'] != str) {
          _statsVisibles['peso'] = str;
          changed = true;
        }
      }
    }

    // ── Altura ────────────────────────────────────────────────
    {
      double? alturaVal;
      // "180cm", "180 cm", "1.80cm" (cm suffix)
      final rCm = RegExp(
        r'(\d+(?:\.\d+)?)\s*(?:cm|centímetros?|centimetros?)',
        caseSensitive: false,
      ).firstMatch(tDot);
      if (rCm != null) {
        final val = double.tryParse(rCm.group(1)!);
        if (val != null) {
          if (val >= 100 && val <= 220) {
            alturaVal = val;
          } else if (val >= 1.0 && val <= 2.5) {
            alturaVal = val * 100;
          }
        }
      }
      // Float metros: "1.80", "1.75" (1.50–2.10)
      if (alturaVal == null) {
        final rM = RegExp(r'(?<!\d)(1\.\d{2})(?!\d)').firstMatch(tDot);
        if (rM != null) {
          final val = double.tryParse(rM.group(1)!);
          if (val != null && val >= 1.5 && val <= 2.1) alturaVal = val * 100;
        }
      }
      // "mido 175" prefix
      if (alturaVal == null) {
        final rMido = RegExp(
          r'(?:mido|talla)\s+(\d+(?:\.\d+)?)',
          caseSensitive: false,
        ).firstMatch(tDot);
        if (rMido != null) {
          final val = double.tryParse(rMido.group(1)!);
          if (val != null && val >= 100 && val <= 220) alturaVal = val;
        }
      }
      // Contextual: número solo si la IA preguntó por altura
      if (alturaVal == null && ultimaIA != null) {
        if (ultimaIA.contains('altura') ||
            ultimaIA.contains('mide') ||
            ultimaIA.contains('estatura') ||
            ultimaIA.contains('talla')) {
          final bare = RegExp(r'^\s*(\d+(?:\.\d+)?)\s*$').firstMatch(tDot);
          if (bare != null) {
            final val = double.tryParse(bare.group(1)!);
            if (val != null) {
              if (val >= 100 && val <= 220) {
                alturaVal = val;
              } else if (val >= 1.5 && val <= 2.1) {
                alturaVal = val * 100;
              }
            }
          }
        }
      }
      if (alturaVal != null) {
        final str = '${alturaVal.round()} cm';
        if (_statsVisibles['altura'] != str) {
          _statsVisibles['altura'] = str;
          changed = true;
        }
      }
    }

    // ── Edad ──────────────────────────────────────────────────
    {
      int? edadVal;
      // Explícita: "25 años", "tengo 25", "25años"
      final rAnios = RegExp(
        r'(\d+)\s*años|\btengo\s+(\d+)',
        caseSensitive: false,
      ).firstMatch(t);
      if (rAnios != null) {
        final raw = rAnios.group(1) ?? rAnios.group(2);
        final val = int.tryParse(raw!);
        if (val != null && val >= 10 && val <= 100) edadVal = val;
      }
      // Contextual: número solo si la IA preguntó por edad
      if (edadVal == null && ultimaIA != null) {
        if (ultimaIA.contains('edad') ||
            ultimaIA.contains('años') ||
            ultimaIA.contains('cuántos')) {
          final bare = RegExp(r'^\s*(\d+)\s*$').firstMatch(t);
          if (bare != null) {
            final val = int.tryParse(bare.group(1)!);
            if (val != null && val >= 10 && val <= 100) edadVal = val;
          }
        }
      }
      if (edadVal != null) {
        final str = '$edadVal años';
        if (_statsVisibles['edad'] != str) {
          _statsVisibles['edad'] = str;
          changed = true;
        }
      }
    }

    // ── Días ──────────────────────────────────────────────────
    final diasMatch = RegExp(r'(\d)\s*día', caseSensitive: false).firstMatch(t);
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

    // ── Objetivo ──────────────────────────────────────────────
    final objetivo = _detectarObjetivo(t);
    if (objetivo != null && _statsVisibles['objetivo'] != objetivo) {
      _statsVisibles['objetivo'] = objetivo;
      changed = true;
    }

    // ── Deporte ───────────────────────────────────────────────
    final deporte = _detectarDeporte(t);
    if (deporte != null && _statsVisibles['deporte'] != deporte) {
      _statsVisibles['deporte'] = deporte;
      changed = true;
    }

    // ── Partes iluminadas ─────────────────────────────────────
    final nuevasPartes = _detectarPartesIluminadas(t);
    if (nuevasPartes.isNotEmpty) {
      final antes = _partesIluminadas.length;
      _partesIluminadas.addAll(nuevasPartes);
      if (_partesIluminadas.length != antes) changed = true;
    }

    if (changed) notifyListeners();
  }

  // ── Contexto: último mensaje de la IA ────────────────────────

  String? _ultimaMensajeIA() {
    for (int i = _mensajes.length - 1; i >= 0; i--) {
      if (!_mensajes[i].esUsuario && !_mensajes[i].estaCargando) {
        return _mensajes[i].contenido.toLowerCase();
      }
    }
    return null;
  }

  // ── Detectores estáticos ──────────────────────────────────────

  static String? _detectarObjetivo(String t) {
    if (t.contains('perder') ||
        t.contains('adelgazar') ||
        t.contains('bajar') ||
        t.contains('grasa') ||
        t.contains('quemar')) {
      return 'Perder grasa';
    }
    if (t.contains('ganar') ||
        t.contains('volumen') ||
        t.contains('músculo') ||
        t.contains('musculo') ||
        t.contains('masa')) {
      return 'Ganar músculo';
    }
    if (t.contains('recomposición') || t.contains('recomposicion')) {
      return 'Recomposición';
    }
    if (t.contains('rendimiento') ||
        t.contains('competir') ||
        t.contains('resistencia')) {
      return 'Rendimiento';
    }
    if (t.contains('mantener') ||
        t.contains('definir') ||
        t.contains('tonificar')) {
      return 'Mantener';
    }
    if (t.contains('salud') ||
        t.contains('bienestar') ||
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

      // 1. Guardar local (fuente de verdad, nunca falla)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'user_profile', jsonEncode(_perfilEnConstruccion.toJson()));
      await prefs.setBool('onboarding_completado', true);

      // 2. Navegar inmediatamente
      _onboardingCompletado = true;
      notifyListeners();

      // 3. Sincronizar con Firestore en background (no crítico)
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirestoreService()
              .guardarPerfil(_perfilEnConstruccion, uid)
              .timeout(const Duration(seconds: 8));
        }
      } catch (_) {
        // Firestore error no crítico: el perfil ya está guardado localmente
      }
    } catch (_) {
      // JSON inválido — continuamos la conversación
    }
  }
}
