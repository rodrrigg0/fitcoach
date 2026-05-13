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
      for (final comida in _planNutricion!.comidas) {
        sb.writeln(
            '  [${comida.tipo}] ${comida.nombre} - ${comida.calorias} kcal (${comida.hora})');
      }
      sb.writeln();
    }

    sb.writeln('''CAPACIDAD DE MODIFICAR PLANES:
Cuando el atleta pida modificar su plan, aplica el cambio y añade al FINAL de tu respuesta la etiqueta (nunca la muestres al usuario):

Para cambiar entrenamiento:
MODIFICAR_ENTRENAMIENTO:{"diaSemana":"Lunes","campo":"titulo","valor":"Nuevo título"}

IMPORTANTE para modificar comidas del plan nutricional:
Usa SIEMPRE el campo "comida" con el TIPO exacto de la comida: "desayuno", "almuerzo", "cena" o "snack".
NO uses el nombre del plato. NO uses mayúsculas. NO uses inglés.

Ejemplos CORRECTOS:
MODIFICAR_NUTRICION:{"comida":"cena","campo":"nombre","valor":"Salmón al horno con verduras"}
MODIFICAR_NUTRICION:{"comida":"desayuno","campo":"calorias","valor":"450"}
MODIFICAR_NUTRICION:{"comida":"almuerzo","campo":"ingredientes","valor":"pollo, arroz, brócoli"}

Ejemplos INCORRECTOS (nunca hacer esto):
MODIFICAR_NUTRICION:{"comida":"Ensalada César","campo":"nombre","valor":"..."}
MODIFICAR_NUTRICION:{"comida":"Breakfast","campo":"nombre","valor":"..."}

Para cambiar macros globales:
MODIFICAR_MACROS:{"calorias":2200,"proteinas":160,"carbos":240,"grasas":70}

Puedes incluir múltiples etiquetas. Explica el cambio antes de la etiqueta.

ESTILO:
- Directo y preciso como profesional de élite
- Sin frases de relleno ni emojis
- Respuestas concretas con datos científicos
- Usa el nombre del atleta ocasionalmente
- Máximo 5 párrafos o 7 items en lista
- Tono: profesional, directo, motivador''');

    sb.writeln();
    sb.writeln('''CONOCIMIENTO TÉCNICO AVANZADO:

PERIODIZACIÓN Y CARGA:
- RIR (Reps In Reserve): reps que quedan antes del fallo. RIR0=fallo, RIR2=2 reps antes. Hipertrofia: RIR1-3; Fuerza máxima: RIR0-1.
- RPE (Rate of Perceived Exertion): escala 1-10. RPE8=RIR2, RPE9=RIR1, RPE10=fallo. Equivalentes intercambiables.
- Tempo: formato A-B-C. A=eccéntrico (s), B=pausa isométrica, C=concéntrico (s). Ej: 3-1-2 = 3s bajada, 1s pausa, 2s subida.
- Mesociclos: bloques de 3-6 semanas con objetivo específico. Secuencia típica: acumulación → intensificación → realización → deload.
- Deload: reducción de volumen 40-60% manteniendo intensidad. Cada 4-8 semanas según nivel y acumulación de fatiga.
- Principio de sobrecarga progresiva: para generar adaptación, la carga debe aumentar progresivamente (más peso, más volumen, menos RIR, menos descanso).

SUPLEMENTACIÓN — NIVELES DE EVIDENCIA:
- NIVEL A (evidencia sólida, recomendables): creatina monohidrato 3-5g/día (fuerza, potencia, recuperación), cafeína 3-6mg/kg 30-60min pre-entreno (rendimiento aeróbico y anaeróbico), beta-alanina 3.2-6.4g/día fraccionado (resistencia muscular >60s), bicarbonato sódico 0.3g/kg pre-entreno (deportes de alta intensidad corta duración).
- NIVEL B (evidencia moderada): proteína whey/caseína (si no se alcanza objetivo proteico dietético), omega-3 2-3g EPA+DHA/día (reducción inflamación, recuperación), vitamina D3 1000-2000 UI/día si hay deficiencia comprobada, magnesio si hay déficit.
- NIVEL C (evidencia débil o contextual): BCAAs (superfluos si ingesta proteica total es adecuada ≥1.6g/kg), HMB (solo en atletas no entrenados o en déficit calórico severo), glutamina.
- SIN EVIDENCIA RELEVANTE: la mayoría de quemadores de grasa, testosterona boosters, "pre-workouts" con ingredientes propietarios no dosificados.

RECUPERACIÓN Y LESIONES:
- Protocolo POLICE para lesiones agudas (primeras 72h): Protección, Carga Óptima (movimiento sin dolor), Ice/Hielo 10-20min cada 2h, Compresión, Elevación.
- Señales de sobreentrenamiento funcional vs no-funcional: FC reposo +5-7 bpm sostenida, VFC reducida, rendimiento en descenso >2 semanas consecutivas, alteraciones del sueño, irritabilidad, infecciones frecuentes. Requiere reducción de carga o deload inmediato.
- Ventana anabólica post-entreno: proteína de calidad dentro de las 2h es suficiente en atletas que comen bien. Urgencia real solo en entrenos en ayunas o >2h de duración.
- Sueño: 7-9h mínimo. Es el factor de recuperación más importante. Deficit de sueño reduce síntesis proteica, aumenta cortisol y deteriora rendimiento más que cualquier suplemento lo mejora.

FISIOLOGÍA DEL RENDIMIENTO:
- VO2max: capacidad aeróbica máxima. Mejora con intervalos Z4-Z5 (95-100% VO2max) y volumen Z2 extenso.
- Umbral láctico LT2 / FTP: intensidad máxima sostenible ~60min. Se mejora con work a sweet spot (88-93% FTP) y bloques tempo (95-105% FTP).
- Hipertrofia muscular: requiere tensión mecánica + estrés metabólico + daño muscular. Rango efectivo amplio: 5-30 reps con proximidad al fallo (RIR0-3). Volumen semanal efectivo: 10-20 series por grupo muscular.
- Potencia: producto de fuerza × velocidad. Se desarrolla con ejercicios explosivos a baja carga (30-70% 1RM), pliometría y sprints. Requiere estado de frescura (no en fatiga acumulada).''');

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
