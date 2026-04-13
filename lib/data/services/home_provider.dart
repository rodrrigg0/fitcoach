import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/models/workout_plan.dart';
import 'package:fitcoach/data/models/meal_plan.dart';
import 'package:fitcoach/data/models/chat_message.dart';
import 'package:fitcoach/data/services/ai_service.dart';

class HomeProvider extends ChangeNotifier {
  static const _keyPerfil = 'user_profile';
  static const _keyWorkoutPlan = 'workout_plan';
  static const _keyMealPlan = 'meal_plan';
  static const _keyDiasCompletados = 'dias_completados';
  static const _keySueno = 'sueno_hoy';
  static const _keySuenoFecha = 'sueno_fecha';

  final AIService _ai = AIService();

  UserProfile? _perfil;
  WorkoutPlan? _planEntrenamiento;
  MealPlan? _planNutricion;
  bool _cargandoPlan = false;
  bool _cargandoNutricion = false;
  bool _cargando = true;
  String? _error;
  int _horasSueno = 0;
  bool _suenoRegistradoHoy = false;
  List<String> _diasCompletados = [];

  UserProfile? get perfil => _perfil;
  WorkoutPlan? get planEntrenamiento => _planEntrenamiento;
  MealPlan? get planNutricion => _planNutricion;
  bool get cargandoPlan => _cargandoPlan;
  bool get cargandoNutricion => _cargandoNutricion;
  bool get cargando => _cargando;
  String? get error => _error;
  int get horasSueno => _horasSueno;
  bool get suenoRegistradoHoy => _suenoRegistradoHoy;

  WorkoutDay? get entrenamientoHoy {
    if (_planEntrenamiento == null) return null;
    final idx = DateTime.now().weekday - 1; // 0=Lunes
    final day = _planEntrenamiento!.semana[idx];
    return day.esDescanso ? null : day;
  }

  WorkoutDay get diaHoy {
    if (_planEntrenamiento == null) return WorkoutDay.descanso();
    return _planEntrenamiento!.semana[DateTime.now().weekday - 1];
  }

  List<Meal> get comidasHoy => _planNutricion?.comidas ?? [];

  int get caloriasObjetivo {
    if (_perfil == null) return 2000;
    // Harris-Benedict BMR
    double bmr;
    final p = _perfil!;
    if (p.sexo.toLowerCase() == 'masculino' || p.sexo.toLowerCase() == 'hombre') {
      bmr = 88.362 + (13.397 * p.peso) + (4.799 * p.altura) - (5.677 * p.edad);
    } else {
      bmr = 447.593 + (9.247 * p.peso) + (3.098 * p.altura) - (4.330 * p.edad);
    }
    // Activity multiplier based on days per week
    final double multiplier;
    if (p.diasEntrenamiento <= 1) {
      multiplier = 1.2;
    } else if (p.diasEntrenamiento <= 3) {
      multiplier = 1.375;
    } else if (p.diasEntrenamiento <= 5) {
      multiplier = 1.55;
    } else {
      multiplier = 1.725;
    }
    double tdee = bmr * multiplier;
    // Adjust for goal
    if (p.objetivo.toLowerCase().contains('perder') ||
        p.objetivo.toLowerCase().contains('adelgaz')) {
      tdee -= 300;
    } else if (p.objetivo.toLowerCase().contains('ganar') ||
        p.objetivo.toLowerCase().contains('masa') ||
        p.objetivo.toLowerCase().contains('volumen')) {
      tdee += 300;
    }
    return tdee.round();
  }

  String get saludo {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  List<bool> get completadosPorDia {
    final hoy = DateTime.now();
    return List.generate(7, (i) {
      final dia = hoy.subtract(Duration(days: hoy.weekday - 1 - i));
      final key = _isoDate(dia);
      return _diasCompletados.contains(key);
    });
  }

  int get rachaActual {
    int racha = 0;
    final hoy = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final dia = hoy.subtract(Duration(days: i));
      if (_diasCompletados.contains(_isoDate(dia))) {
        racha++;
      } else {
        break;
      }
    }
    return racha;
  }

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ─── Carga inicial ─────────────────────────────────────────

  Future<void> cargarDatos() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Perfil
      final perfilJson = prefs.getString(_keyPerfil);
      if (perfilJson != null) {
        _perfil = UserProfile.fromJson(
            jsonDecode(perfilJson) as Map<String, dynamic>);
      }

      // Plan entrenamiento
      final workoutJson = prefs.getString(_keyWorkoutPlan);
      if (workoutJson != null) {
        _planEntrenamiento = WorkoutPlan.fromJson(
            jsonDecode(workoutJson) as Map<String, dynamic>);
      }

      // Plan nutrición
      final mealJson = prefs.getString(_keyMealPlan);
      if (mealJson != null) {
        _planNutricion = MealPlan.fromJson(
            jsonDecode(mealJson) as Map<String, dynamic>);
      }

      // Días completados
      _diasCompletados = prefs.getStringList(_keyDiasCompletados) ?? [];

      // Sueño
      final suenoFecha = prefs.getString(_keySuenoFecha);
      final hoyStr = _isoDate(DateTime.now());
      if (suenoFecha == hoyStr) {
        _horasSueno = prefs.getInt(_keySueno) ?? 0;
        _suenoRegistradoHoy = true;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // ─── Generar planes ────────────────────────────────────────

  Future<void> generarPlanEntrenamiento() async {
    if (_perfil == null || _cargandoPlan) return;
    _cargandoPlan = true;
    _error = null;
    notifyListeners();

    try {
      final prompt = _buildWorkoutPrompt();
      final respuesta = await _ai.enviarMensaje(
        historial: const [],
        mensajeUsuario: prompt,
        systemPrompt:
            'Eres un entrenador personal experto. Responde SOLO con JSON válido, sin texto adicional ni bloques de código.',
        maxTokens: 4000,
      );

      final cleanJson = _extraerJson(respuesta);
      final plan = WorkoutPlan.fromJson(
          jsonDecode(cleanJson) as Map<String, dynamic>);
      _planEntrenamiento = plan;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyWorkoutPlan, jsonEncode(plan.toJson()));
    } catch (e) {
      _error = 'Error generando plan: $e';
    } finally {
      _cargandoPlan = false;
      notifyListeners();
    }
  }

  Future<void> generarPlanNutricion() async {
    if (_perfil == null || _cargandoNutricion) return;
    _cargandoNutricion = true;
    _error = null;
    notifyListeners();

    try {
      final prompt = _buildNutritionPrompt();
      final respuesta = await _ai.enviarMensaje(
        historial: const [],
        mensajeUsuario: prompt,
        systemPrompt:
            'Eres un nutricionista deportivo experto. Responde SOLO con JSON válido, sin texto adicional ni bloques de código.',
        maxTokens: 4000,
      );

      final cleanJson = _extraerJson(respuesta);
      final plan = MealPlan.fromJson(
          jsonDecode(cleanJson) as Map<String, dynamic>);
      _planNutricion = plan;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyMealPlan, jsonEncode(plan.toJson()));
    } catch (e) {
      _error = 'Error generando plan nutricional: $e';
    } finally {
      _cargandoNutricion = false;
      notifyListeners();
    }
  }

  // ─── Acciones del usuario ──────────────────────────────────

  Future<void> marcarDiaCompletado() async {
    final hoy = _isoDate(DateTime.now());
    if (!_diasCompletados.contains(hoy)) {
      _diasCompletados = [..._diasCompletados, hoy];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyDiasCompletados, _diasCompletados);
      notifyListeners();
    }
  }

  Future<void> toggleEntrenamientoCompletado() async {
    if (_planEntrenamiento == null) return;
    final idx = DateTime.now().weekday - 1;
    final dia = _planEntrenamiento!.semana[idx];
    dia.completado = !dia.completado;
    if (dia.completado) await marcarDiaCompletado();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyWorkoutPlan, jsonEncode(_planEntrenamiento!.toJson()));
    notifyListeners();
  }

  Future<void> toggleComidaCompletada(Meal comida) async {
    comida.completada = !comida.completada;
    if (_planNutricion != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _keyMealPlan, jsonEncode(_planNutricion!.toJson()));
    }
    notifyListeners();
  }

  Future<void> registrarSueno(int horas) async {
    _horasSueno = horas;
    _suenoRegistradoHoy = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySueno, horas);
    await prefs.setString(_keySuenoFecha, _isoDate(DateTime.now()));
    notifyListeners();
  }

  // ─── Helpers privados ──────────────────────────────────────

  String _buildWorkoutPrompt() {
    final p = _perfil!;
    return '''Genera un plan de entrenamiento semanal personalizado en JSON con esta estructura exacta:
{
  "semana": [
    {
      "tipo": "gimnasio|deporte|descanso",
      "titulo": "Nombre del entrenamiento",
      "descripcion": "Descripción breve",
      "duracion": 45,
      "lugar": "Gimnasio|Parque|Casa",
      "ejercicios": [
        {"nombre": "Sentadillas", "series": "4x12", "duracion": null, "distancia": null}
      ],
      "porQueHoy": "Razón de este entrenamiento hoy",
      "objetivos": ["Fuerza", "Resistencia"],
      "consejo": "Consejo del día",
      "caracteristicas": ["Piernas", "Glúteos"],
      "completado": false
    }
  ],
  "notaDistribucion": "Explicación de la distribución semanal"
}

Perfil del usuario:
- Nombre: ${p.nombre}, ${p.edad} años, ${p.sexo}
- Peso: ${p.peso} kg, Altura: ${p.altura} cm
- Objetivo: ${p.objetivo}
- Deportes: ${p.deportes.join(', ')}
- Días de entrenamiento: ${p.diasEntrenamiento} días/semana
- Duración sesión: ${p.minutosSesion} minutos
- Lugar: ${p.lugarEntrenamiento}
- Lesiones: ${p.lesiones.isEmpty ? 'Ninguna' : p.lesiones}

Genera exactamente 7 días (índice 0=Lunes, 6=Domingo). Incluye días de descanso según la distribución óptima.''';
  }

  String _buildNutritionPrompt() {
    final p = _perfil!;
    final cals = caloriasObjetivo;
    final proteinas = ((cals * 0.30) / 4).round();
    final carbos = ((cals * 0.45) / 4).round();
    final grasas = ((cals * 0.25) / 9).round();
    return '''Genera un plan nutricional diario en JSON con esta estructura exacta:
{
  "comidas": [
    {
      "tipo": "desayuno|almuerzo|cena|snack",
      "nombre": "Nombre del plato",
      "calorias": 400,
      "proteinas": 30.0,
      "carbohidratos": 45.0,
      "grasas": 12.0,
      "hora": "08:00",
      "ingredientes": ["100g pechuga de pollo", "80g arroz integral"],
      "preparacion": "Instrucciones breves de preparación",
      "completada": false
    }
  ],
  "caloriasObjetivo": $cals,
  "proteinasObjetivo": $proteinas,
  "carbosObjetivo": $carbos,
  "grasasObjetivo": $grasas
}

Perfil:
- Objetivo: ${p.objetivo}
- Dieta: ${p.tipoDieta}
- Alergias: ${p.alergias.isEmpty ? 'Ninguna' : p.alergias.join(', ')}
- Presupuesto semanal: ${p.presupuestoSemanal}€
- Suplementos: ${p.suplementosActuales.isEmpty ? 'Ninguno' : p.suplementosActuales.join(', ')}

Incluye desayuno, almuerzo, cena y 1-2 snacks. Total: ~$cals kcal.''';
  }

  String _extraerJson(String texto) {
    final jsonStart = texto.indexOf('{');
    final jsonEnd = texto.lastIndexOf('}');
    if (jsonStart == -1 || jsonEnd == -1) return texto;
    return texto.substring(jsonStart, jsonEnd + 1);
  }

  // ─── Chat context ──────────────────────────────────────────

  String buildSystemPromptChat() {
    if (_perfil == null) return 'Eres FitCoach, asistente personal de fitness.';
    final p = _perfil!;
    return '''Eres FitCoach, asistente personal de fitness para ${p.nombre}.

Perfil: ${p.edad} años, ${p.sexo}, ${p.peso}kg, ${p.altura}cm.
Objetivo: ${p.objetivo}.
Deportes: ${p.deportes.join(', ')}.
Entrena ${p.diasEntrenamiento} días/semana, ${p.minutosSesion} min/sesión.
Dieta: ${p.tipoDieta}. Alergias: ${p.alergias.isEmpty ? 'ninguna' : p.alergias.join(', ')}.
${p.lesiones.isNotEmpty ? 'Lesiones: ${p.lesiones}.' : ''}

Responde en español, de forma directa y motivadora. Sin emojis. Máximo 3 párrafos.''';
  }

  List<ChatMessage> get historialChat => const [];
}
