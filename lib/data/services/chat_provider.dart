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
import 'package:fitcoach/core/utils/usage_tracker.dart';

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

  // Callbacks para notificar a otros providers cuando se actualiza un plan
  VoidCallback? onPlanEntrenamientoActualizado;
  VoidCallback? onPlanNutricionActualizado;

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

  // ─── System prompt (comprimido) ─────────────────────────────

  String get _systemPrompt {
    final p = _perfil;
    final sb = StringBuffer();

    sb.write('Eres el entrenador personal de ${p?.nombre ?? 'el atleta'}. '
        'Experto en Ciencias del Deporte, nutrición deportiva y farmacología deportiva.\n\n');

    sb.write('ATLETA: ${p?.nombre ?? '-'}, ${p?.edad ?? '-'}a, ${p?.sexo ?? '-'}, '
        '${p?.peso ?? '-'}kg, ${p?.altura ?? '-'}cm\n');
    sb.write('DEPORTE: ${p?.deportes.join('+') ?? '-'} | OBJ: ${p?.objetivo ?? '-'}\n');
    sb.write('LESIONES: ${(p?.lesiones.isEmpty ?? true) ? 'ninguna' : p!.lesiones}\n');
    sb.write('DIETA: ${p?.tipoDieta ?? '-'} | '
        'ALERGIAS: ${(p?.alergias.isEmpty ?? true) ? 'ninguna' : p!.alergias.join(',')}\n');
    sb.write('SUPL: ${(p?.suplementosActuales.isEmpty ?? true) ? 'ninguno' : p!.suplementosActuales.join(',')}\n\n');

    if (_planEntrenamiento != null) {
      sb.write('PLAN ENTRENO: ');
      for (int i = 0; i < _planEntrenamiento!.semana.length; i++) {
        final label = i < _diasLabel.length ? _diasLabel[i] : 'D${i + 1}';
        sb.write('$label:${_planEntrenamiento!.semana[i].titulo}');
        if (i < _planEntrenamiento!.semana.length - 1) sb.write(' | ');
      }
      sb.write('\n');
    }

    if (_planNutricion != null) {
      final n = _planNutricion!;
      sb.write('MACROS: ${n.caloriasObjetivo}kcal '
          'P:${n.proteinasObjetivo.round()}g '
          'C:${n.carbosObjetivo.round()}g '
          'G:${n.grasasObjetivo.round()}g\n');
    }

    sb.write('''
ESTILO: Directo, profesional, sin emojis. Máx 4 párrafos. Usa el nombre del atleta ocasionalmente.

MODIFICAR PLANES (añade al FINAL de tu respuesta, nunca lo muestres al usuario):
Entrenamiento: MODIFICAR_ENTRENAMIENTO:{"diaSemana":"Lunes","campo":"titulo","valor":"..."}
Nutrición — usa SIEMPRE el TIPO (desayuno/almuerzo/cena/snack), NO el nombre del plato:
  MODIFICAR_NUTRICION:{"comida":"cena","campo":"nombre","valor":"Salmón al horno"}
  MODIFICAR_NUTRICION:{"comida":"desayuno","campo":"calorias","valor":"450"}
Macros: MODIFICAR_MACROS:{"calorias":2200,"proteinas":160,"carbos":240,"grasas":70}
''');

    return sb.toString();
  }

  // ─── Enviar mensaje ─────────────────────────────────────────

  Future<void> enviarMensaje(String texto) async {
    if (texto.trim().isEmpty || _enviando) return;

    // Comprueba límite diario
    if (!await UsageTracker.puedeEnviarMensaje()) {
      _mensajes.add(ChatMessage.deIA(
        'Has alcanzado el límite de ${UsageTracker.maxMensajesChat} mensajes '
        'diarios. Vuelve mañana o activa el plan premium para uso ilimitado.',
      ));
      notifyListeners();
      return;
    }

    _mensajes.add(ChatMessage.deUsuario(texto));
    _mensajes.add(ChatMessage.cargando());
    _enviando = true;
    error = null;
    notifyListeners();

    await UsageTracker.registrarMensaje();

    try {
      // Historial completo sin mensajes de sistema ni cargando
      final historialCompleto = _mensajes
          .where((m) => !m.estaCargando && !m.esMensajeSistema)
          .toList();
      // Excluye el último (el mensaje actual que se pasa como mensajeUsuario)
      final sinActual = historialCompleto.length > 1
          ? historialCompleto.sublist(0, historialCompleto.length - 1)
          : <ChatMessage>[];
      // Limita a los últimos 8 mensajes para reducir tokens
      final historialEnvio = sinActual.length > 8
          ? sinActual.sublist(sinActual.length - 8)
          : sinActual;

      final respuestaRaw = await _ai
          .enviarMensaje(
            historial: historialEnvio,
            mensajeUsuario: texto,
            systemPrompt: _systemPrompt,
            modelo: AIModels.haiku,
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
    onPlanEntrenamientoActualizado?.call();
    notifyListeners();
  }

  Future<void> _aplicarCambioNutricion(
      Map<String, dynamic> cambio) async {
    if (_planNutricion == null) return;

    debugPrint('=== APLICANDO CAMBIO NUTRICIÓN ===');
    debugPrint('Cambio recibido: $cambio');

    final String? nombreBuscado =
        cambio['comida']?.toString().toLowerCase().trim();
    final String? campo = cambio['campo']?.toString();
    final valor = cambio['valor'];

    if (nombreBuscado == null || campo == null) {
      debugPrint('Cambio inválido: faltan campos');
      return;
    }

    bool cambioAplicado = false;

    const alias = <String, List<String>>{
      'desayuno': ['breakfast', 'desayuno'],
      'almuerzo': ['lunch', 'almuerzo', 'comida'],
      'cena': ['dinner', 'cena'],
      'snack': ['snack', 'merienda', 'tentempié'],
    };

    final nuevasComidas = _planNutricion!.comidas.map((comida) {
      final tipoMatch =
          comida.tipo.toLowerCase().trim() == nombreBuscado;
      final nombreMatch =
          comida.nombre.toLowerCase().trim().contains(nombreBuscado);

      bool aliasMatch = false;
      for (final entry in alias.entries) {
        if (entry.value.contains(nombreBuscado) &&
            entry.value.contains(comida.tipo.toLowerCase())) {
          aliasMatch = true;
          break;
        }
      }

      if (!tipoMatch && !nombreMatch && !aliasMatch) {
        return comida;
      }

      debugPrint('Comida encontrada: ${comida.nombre} (${comida.tipo})');
      cambioAplicado = true;

      switch (campo) {
        case 'nombre':
          return comida.copyWith(nombre: valor.toString());
        case 'calorias':
          return comida.copyWith(
              calorias:
                  int.tryParse(valor.toString()) ?? comida.calorias);
        case 'proteinas':
          return comida.copyWith(
              proteinas:
                  double.tryParse(valor.toString()) ?? comida.proteinas);
        case 'carbohidratos':
        case 'carbos':
          return comida.copyWith(
              carbohidratos: double.tryParse(valor.toString()) ??
                  comida.carbohidratos);
        case 'grasas':
          return comida.copyWith(
              grasas:
                  double.tryParse(valor.toString()) ?? comida.grasas);
        case 'ingredientes':
          return comida.copyWith(
              ingredientes: valor is List
                  ? List<String>.from(valor)
                  : valor
                      .toString()
                      .split(',')
                      .map((s) => s.trim())
                      .toList());
        case 'preparacion':
          return comida.copyWith(preparacion: valor.toString());
        default:
          debugPrint('Campo no reconocido: $campo');
          return comida;
      }
    }).toList();

    if (!cambioAplicado) {
      debugPrint(
          'ADVERTENCIA: No se encontró la comida "$nombreBuscado"');
      debugPrint('Comidas disponibles:');
      for (final comida in _planNutricion!.comidas) {
        debugPrint(
            '  - tipo: ${comida.tipo}, nombre: ${comida.nombre}');
      }
      return;
    }

    _planNutricion = _planNutricion!.copyWith(comidas: nuevasComidas);
    debugPrint('Plan actualizado correctamente');

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.guardarPlanNutricion(_planNutricion!, uid);
        debugPrint('Guardado en Firestore OK');
      } catch (e) {
        debugPrint('Error Firestore: $e');
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _keyMealPlan, jsonEncode(_planNutricion!.toJson()));
      debugPrint('Guardado en SharedPrefs OK');
    } catch (e) {
      debugPrint('Error SharedPrefs: $e');
    }

    onPlanNutricionActualizado?.call();
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
    onPlanNutricionActualizado?.call();
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
