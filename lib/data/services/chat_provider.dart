import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/data/models/chat_message.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/models/workout_plan.dart';
import 'package:fitcoach/data/models/meal_plan.dart';
import 'package:fitcoach/data/services/ai_service.dart';
import 'package:fitcoach/data/services/firestore_service.dart';

class ChatProvider extends ChangeNotifier {
  static const _keyPerfil = 'user_profile';
  static const _keyWorkoutPlan = 'workout_plan';
  static const _keyMealPlan = 'meal_plan';

  static const _diasLabel = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves',
    'Viernes', 'Sábado', 'Domingo',
  ];
  static const _diasIdx = {
    'Lunes': 0, 'Martes': 1, 'Miércoles': 2, 'Jueves': 3,
    'Viernes': 4, 'Sábado': 5, 'Domingo': 6,
  };

  final AIService _ai = AIService();
  final FirestoreService _firestore = FirestoreService();

  UserProfile? _perfil;
  WorkoutPlan? _planEntrenamiento;
  MealPlan? _planNutricion;
  final List<ChatMessage> _mensajes = [];
  bool _enviando = false;
  bool _planActualizado = false;
  bool _disposed = false;
  String? error;

  UserProfile? get perfil => _perfil;
  WorkoutPlan? get planEntrenamiento => _planEntrenamiento;
  MealPlan? get planNutricion => _planNutricion;
  List<ChatMessage> get mensajes => List.unmodifiable(_mensajes);
  bool get enviando => _enviando;
  bool get planActualizado => _planActualizado;
  bool get tieneHistorial => _mensajes.isNotEmpty;

  void resetPlanActualizado() {
    _planActualizado = false;
  }

  void limpiarChat() {
    _mensajes.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ─── Inicialización ─────────────────────────────────────────

  Future<void> inicializar() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final perfilJson = prefs.getString(_keyPerfil);
      if (perfilJson != null) {
        _perfil = UserProfile.fromJson(
            jsonDecode(perfilJson) as Map<String, dynamic>);
      }

      final workoutJson = prefs.getString(_keyWorkoutPlan);
      if (workoutJson != null) {
        _planEntrenamiento = WorkoutPlan.fromJson(
            jsonDecode(workoutJson) as Map<String, dynamic>);
      }

      final mealJson = prefs.getString(_keyMealPlan);
      if (mealJson != null) {
        _planNutricion = MealPlan.fromJson(
            jsonDecode(mealJson) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('ChatProvider.inicializar prefs error: $e');
    }

    // Carga historial desde Firestore
    if (_mensajes.isEmpty) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          final historial = await _firestore
              .cargarHistorialChat(uid)
              .timeout(const Duration(seconds: 5));
          _mensajes.addAll(historial);
        } catch (e) {
          debugPrint('ChatProvider: error cargando historial: $e');
        }
      }
    }

    notifyListeners();
  }

  // ─── System prompt ──────────────────────────────────────────

  String get _systemPrompt {
    final sb = StringBuffer();
    final p = _perfil;

    sb.writeln(
        'Eres el mejor entrenador personal del mundo con 20 años entrenando '
        'atletas de élite. Doctorado en Ciencias del Deporte. Especialista en '
        'nutrición deportiva y farmacología deportiva.');
    sb.writeln();
    sb.writeln('PERFIL DEL ATLETA:');
    sb.writeln('Nombre: ${p?.nombre ?? '-'}');
    sb.writeln('Edad: ${p?.edad ?? '-'} años · Sexo: ${p?.sexo ?? '-'}');
    sb.writeln('Peso: ${p?.peso ?? '-'} kg · Altura: ${p?.altura ?? '-'} cm');
    sb.writeln('Deporte: ${p?.deportes.join(', ') ?? '-'}');
    sb.writeln('Objetivo: ${p?.objetivo ?? '-'}');
    sb.writeln('Dieta: ${p?.tipoDieta ?? '-'}');
    sb.writeln(
        'Alergias: ${(p?.alergias.isEmpty ?? true) ? 'Ninguna' : p!.alergias.join(', ')}');
    sb.writeln(
        'Lesiones: ${(p?.lesiones.isEmpty ?? true) ? 'Ninguna' : p!.lesiones}');
    sb.writeln(
        'Suplementos: ${(p?.suplementosActuales.isEmpty ?? true) ? 'Ninguno' : p!.suplementosActuales.join(', ')}');
    sb.writeln(
        'Días/semana: ${p?.diasEntrenamiento ?? '-'} · Min/sesión: ${p?.minutosSesion ?? '-'}');
    sb.writeln();

    if (_planEntrenamiento != null) {
      sb.writeln('PLAN DE ENTRENAMIENTO ACTUAL:');
      for (int i = 0; i < _planEntrenamiento!.semana.length; i++) {
        final dia = _planEntrenamiento!.semana[i];
        final label =
            i < _diasLabel.length ? _diasLabel[i] : 'Día ${i + 1}';
        sb.writeln(
            '$label: ${dia.titulo} (${dia.tipo}) - ${dia.descripcion} - ${dia.duracion}min en ${dia.lugar}');
      }
      sb.writeln('Distribución: ${_planEntrenamiento!.notaDistribucion}');
      sb.writeln();
    }

    if (_planNutricion != null) {
      sb.writeln('PLAN NUTRICIONAL ACTUAL:');
      sb.writeln(
          'Calorías: ${_planNutricion!.caloriasObjetivo} kcal/día');
      sb.writeln(
          'Proteínas: ${_planNutricion!.proteinasObjetivo}g | Carbos: ${_planNutricion!.carbosObjetivo}g | Grasas: ${_planNutricion!.grasasObjetivo}g');
      sb.writeln();
    }

    sb.writeln('''CAPACIDAD DE MODIFICAR PLANES:
Cuando el atleta pida modificar su plan, aplica el cambio y añade al FINAL de tu respuesta la etiqueta (nunca la muestres al usuario):

Para cambiar entrenamiento:
MODIFICAR_ENTRENAMIENTO:{"diaSemana":"Lunes","campo":"titulo","valor":"Nuevo título"}

Para cambiar campo de nutrición:
MODIFICAR_NUTRICION:{"comida":"Almuerzo","campo":"nombre","valor":"Nuevo nombre"}

Para cambiar macros:
MODIFICAR_MACROS:{"calorias":2200,"proteinas":160,"carbos":240,"grasas":70}

Puedes incluir múltiples etiquetas. Explica el cambio antes de la etiqueta.

ESTILO:
- Directo y preciso como profesional de élite
- Sin frases de relleno ni emojis
- Respuestas concretas con datos científicos
- Usa el nombre del atleta ocasionalmente
- Máximo 5 párrafos o 7 items en lista
- Tono: profesional, directo, motivador''');

    return sb.toString();
  }

  // ─── Enviar mensaje ─────────────────────────────────────────

  Future<void> enviarMensaje(String texto) async {
    if (texto.trim().isEmpty || _enviando) return;

    _mensajes.add(ChatMessage.deUsuario(texto));
    _mensajes.add(ChatMessage.cargando());
    _enviando = true;
    error = null;
    notifyListeners();

    try {
      final historial = _mensajes
          .where((m) => !m.estaCargando && !m.esMensajeSistema)
          .toList();
      final historialEnvio = historial.length > 1
          ? historial.sublist(0, historial.length - 1)
          : <ChatMessage>[];

      final respuestaRaw = await _ai
          .enviarMensaje(
            historial: historialEnvio,
            mensajeUsuario: texto,
            systemPrompt: _systemPrompt,
          )
          .timeout(const Duration(seconds: 30));

      final respuestaLimpia = await _procesarCambios(respuestaRaw);

      _mensajes.removeLast(); // elimina cargando
      _mensajes.add(ChatMessage.deIA(respuestaLimpia));
    } catch (e) {
      _mensajes.removeLast();
      error = e.toString();
      _mensajes.add(ChatMessage.deIA(
          'No he podido procesar tu mensaje. Comprueba tu conexión.'));
    } finally {
      _enviando = false;
      notifyListeners();
      _guardarHistorial();
    }
  }

  // ─── Procesar cambios ───────────────────────────────────────

  Future<String> _procesarCambios(String respuesta) async {
    String limpia = respuesta;
    bool huboCambios = false;

    final regexEntreno =
        RegExp(r'MODIFICAR_ENTRENAMIENTO:(\{[^}]+\})');
    for (final match in regexEntreno.allMatches(respuesta)) {
      try {
        final cambio =
            jsonDecode(match.group(1)!) as Map<String, dynamic>;
        await _aplicarCambioEntrenamiento(cambio);
        huboCambios = true;
      } catch (e) {
        debugPrint('Error cambio entrenamiento: $e');
      }
      limpia = limpia.replaceAll(match.group(0)!, '');
    }

    final regexNutricion =
        RegExp(r'MODIFICAR_NUTRICION:(\{[^}]+\})');
    for (final match in regexNutricion.allMatches(respuesta)) {
      try {
        final cambio =
            jsonDecode(match.group(1)!) as Map<String, dynamic>;
        await _aplicarCambioNutricion(cambio);
        huboCambios = true;
      } catch (e) {
        debugPrint('Error cambio nutricion: $e');
      }
      limpia = limpia.replaceAll(match.group(0)!, '');
    }

    final regexMacros = RegExp(r'MODIFICAR_MACROS:(\{[^}]+\})');
    for (final match in regexMacros.allMatches(respuesta)) {
      try {
        final cambio =
            jsonDecode(match.group(1)!) as Map<String, dynamic>;
        await _aplicarCambioMacros(cambio);
        huboCambios = true;
      } catch (e) {
        debugPrint('Error cambio macros: $e');
      }
      limpia = limpia.replaceAll(match.group(0)!, '');
    }

    if (huboCambios) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_disposed) {
          _mensajes
              .add(ChatMessage.sistema('Plan actualizado correctamente'));
          _planActualizado = true;
          notifyListeners();
        }
      });
    }

    return limpia.trim();
  }

  Future<void> _aplicarCambioEntrenamiento(
      Map<String, dynamic> cambio) async {
    if (_planEntrenamiento == null) return;
    final diaNombre = cambio['diaSemana'] as String?;
    final campo = cambio['campo'] as String?;
    final valor = cambio['valor'];
    if (diaNombre == null || campo == null || valor == null) return;

    final idx = _diasIdx[diaNombre];
    if (idx == null || idx >= _planEntrenamiento!.semana.length) return;

    final dia = _planEntrenamiento!.semana[idx];
    _planEntrenamiento!.semana[idx] = dia.copyWith(
      titulo: campo == 'titulo' ? valor.toString() : null,
      tipo: campo == 'tipo' ? valor.toString() : null,
      descripcion:
          campo == 'descripcion' ? valor.toString() : null,
      duracion: campo == 'duracion'
          ? (int.tryParse(valor.toString()) ?? dia.duracion)
          : null,
      lugar: campo == 'lugar' ? valor.toString() : null,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyWorkoutPlan, jsonEncode(_planEntrenamiento!.toJson()));

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.guardarPlanEntrenamiento(
            _planEntrenamiento!, uid);
      } catch (e) {
        debugPrint('Error guardando plan entreno: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _aplicarCambioNutricion(
      Map<String, dynamic> cambio) async {
    if (_planNutricion == null) return;
    final comidaId = cambio['comida'] as String?;
    final campo = cambio['campo'] as String?;
    final valor = cambio['valor'];
    if (comidaId == null || campo == null || valor == null) return;

    final idx = _planNutricion!.comidas.indexWhere((m) =>
        m.tipo.toLowerCase() == comidaId.toLowerCase() ||
        m.nombre.toLowerCase().contains(comidaId.toLowerCase()));
    if (idx == -1) return;

    final m = _planNutricion!.comidas[idx];
    _planNutricion!.comidas[idx] = Meal(
      tipo: m.tipo,
      nombre: campo == 'nombre' ? valor.toString() : m.nombre,
      calorias: campo == 'calorias'
          ? (int.tryParse(valor.toString()) ?? m.calorias)
          : m.calorias,
      proteinas: m.proteinas,
      carbohidratos: m.carbohidratos,
      grasas: m.grasas,
      hora: campo == 'hora' ? valor.toString() : m.hora,
      ingredientes: m.ingredientes,
      preparacion:
          campo == 'preparacion' ? valor.toString() : m.preparacion,
      completada: m.completada,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyMealPlan, jsonEncode(_planNutricion!.toJson()));

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.guardarPlanNutricion(_planNutricion!, uid);
      } catch (e) {
        debugPrint('Error guardando plan nutricion: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _aplicarCambioMacros(
      Map<String, dynamic> cambio) async {
    if (_planNutricion == null) return;
    _planNutricion = _planNutricion!.copyWith(
      caloriasObjetivo:
          (cambio['calorias'] as num?)?.toInt(),
      proteinasObjetivo:
          (cambio['proteinas'] as num?)?.toDouble(),
      carbosObjetivo: (cambio['carbos'] as num?)?.toDouble(),
      grasasObjetivo: (cambio['grasas'] as num?)?.toDouble(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyMealPlan, jsonEncode(_planNutricion!.toJson()));

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.guardarPlanNutricion(_planNutricion!, uid);
      } catch (e) {
        debugPrint('Error guardando macros: $e');
      }
    }
    notifyListeners();
  }

  // ─── Historial ──────────────────────────────────────────────

  void _guardarHistorial() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ultimos = _mensajes.length > 50
        ? _mensajes.sublist(_mensajes.length - 50)
        : List<ChatMessage>.from(_mensajes);
    _firestore.guardarHistorialChat(uid, ultimos).catchError((e) {
      debugPrint('Error guardando historial: $e');
    });
  }
}
