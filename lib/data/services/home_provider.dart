import 'dart:async';
import 'dart:convert';
import 'dart:math' show min;
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/models/workout_plan.dart';
import 'package:fitcoach/data/models/meal_plan.dart';
import 'package:fitcoach/data/models/chat_message.dart';
import 'package:fitcoach/data/models/shopping_item.dart';
import 'package:fitcoach/data/models/weight_log.dart';
import 'package:fitcoach/data/services/ai_service.dart';
import 'package:fitcoach/data/services/firestore_service.dart';

class HomeProvider extends ChangeNotifier {
  static const _keyPerfil = 'user_profile';
  static const _keyWorkoutPlan = 'workout_plan';
  static const _keyMealPlan = 'meal_plan';
  static const _keyDiasCompletados = 'dias_completados';
  static const _keySueno = 'sueno_hoy';
  static const _keySuenoFecha = 'sueno_fecha';
  static const _keyListaCompra = 'lista_compra';

  final AIService _ai = AIService();
  final FirestoreService _firestoreService = FirestoreService();

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
  List<ShoppingItem> _listaCompra = [];
  bool _generandoLista = false;
  List<WeightLog> _registrosPeso = [];
  bool _cargandoPesos = false;

  UserProfile? get perfil => _perfil;
  WorkoutPlan? get planEntrenamiento => _planEntrenamiento;
  MealPlan? get planNutricion => _planNutricion;
  bool get cargandoPlan => _cargandoPlan;
  bool get cargandoNutricion => _cargandoNutricion;
  bool get cargando => _cargando;
  String? get error => _error;
  int get horasSueno => _horasSueno;
  bool get suenoRegistradoHoy => _suenoRegistradoHoy;
  List<ShoppingItem> get listaCompra => _listaCompra;
  bool get generandoLista => _generandoLista;
  List<WeightLog> get registrosPeso => _registrosPeso;
  bool get cargandoPesos => _cargandoPesos;

  WorkoutDay? get entrenamientoHoy {
    if (_planEntrenamiento == null) return null;
    final idx = DateTime.now().weekday - 1;
    final day = _planEntrenamiento!.semana[idx];
    return day.esDescanso ? null : day;
  }

  WorkoutDay get diaHoy {
    if (_planEntrenamiento == null) return WorkoutDay.descanso();
    return _planEntrenamiento!.semana[DateTime.now().weekday - 1];
  }

  static const _kDiasEspanol = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  List<Meal> get comidasHoy {
    if (_planNutricion == null) return [];
    final diasList = _planNutricion!.dias;
    if (diasList.isNotEmpty) {
      final hoy = _kDiasEspanol[DateTime.now().weekday - 1];
      for (final dia in diasList) {
        if (dia.diaSemana == hoy) return dia.comidas;
      }
      final idx = (DateTime.now().weekday - 1).clamp(0, diasList.length - 1);
      return diasList[idx].comidas;
    }
    return _planNutricion!.comidas;
  }

  int get caloriasConsumidas =>
      _planNutricion?.caloriasConsumidas ?? 0;

  double get porcentajeCalorias {
    final obj = caloriasObjetivo;
    if (obj == 0) return 0;
    return (caloriasConsumidas / obj).clamp(0.0, 1.0);
  }

  Meal? get proximaComida {
    final comidas = comidasHoy.where((m) => !m.completada).toList();
    if (comidas.isEmpty) return null;
    final ahora = DateTime.now();
    for (final m in comidas) {
      final partes = m.hora.split(':');
      if (partes.length == 2) {
        final h = int.tryParse(partes[0]) ?? 0;
        final min = int.tryParse(partes[1]) ?? 0;
        if (h > ahora.hour || (h == ahora.hour && min >= ahora.minute)) {
          return m;
        }
      }
    }
    return comidas.first;
  }

  int get caloriasObjetivo {
    if (_perfil == null) return 2000;
    double bmr;
    final p = _perfil!;
    if (p.sexo.toLowerCase() == 'masculino' ||
        p.sexo.toLowerCase() == 'hombre') {
      bmr = 88.362 + (13.397 * p.peso) + (4.799 * p.altura) - (5.677 * p.edad);
    } else {
      bmr = 447.593 + (9.247 * p.peso) + (3.098 * p.altura) - (4.330 * p.edad);
    }
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
      final uid = FirebaseAuth.instance.currentUser?.uid;

      // Perfil — SharedPreferences primero, luego Firestore
      final perfilJson = prefs.getString(_keyPerfil);
      if (perfilJson != null) {
        _perfil = UserProfile.fromJson(
            jsonDecode(perfilJson) as Map<String, dynamic>);
      }
      if (_perfil == null && uid != null) {
        try {
          _perfil = await _firestoreService
              .cargarPerfil(uid)
              .timeout(const Duration(seconds: 5));
          if (_perfil != null) {
            await prefs.setString(
                _keyPerfil, jsonEncode(_perfil!.toJson()));
          }
        } catch (e) {
          debugPrint('HomeProvider: error cargando perfil de Firestore: $e');
        }
      }

      // Planes — Firestore (con fallback a SharedPreferences internamente)
      if (uid != null) {
        try {
          _planEntrenamiento = await _firestoreService
              .cargarPlanEntrenamiento(uid)
              .timeout(const Duration(seconds: 8));
        } catch (_) {
          final workoutJson = prefs.getString(_keyWorkoutPlan);
          if (workoutJson != null) {
            _planEntrenamiento = WorkoutPlan.fromJson(
                jsonDecode(workoutJson) as Map<String, dynamic>);
          }
        }
        try {
          _planNutricion = await _firestoreService
              .cargarPlanNutricion(uid)
              .timeout(const Duration(seconds: 8));
        } catch (_) {
          final mealJson = prefs.getString(_keyMealPlan);
          if (mealJson != null) {
            _planNutricion = MealPlan.fromJson(
                jsonDecode(mealJson) as Map<String, dynamic>);
          }
        }
      } else {
        // Sin uid — solo SharedPreferences
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

      // Lista de la compra
      try {
        final listaJson = prefs.getString(_keyListaCompra);
        if (listaJson != null) {
          final list = jsonDecode(listaJson) as List<dynamic>;
          _listaCompra = list
              .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        debugPrint('HomeProvider: error cargando lista compra: $e');
      }

      // Pesos — carga asíncrona desde Firestore
      if (uid != null) {
        unawaited(_cargarPesosInterno(uid));
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
      debugPrint('=== GENERANDO PLAN DE ENTRENAMIENTO ===');
      final respuesta = await _ai.enviarMensaje(
        historial: const [],
        mensajeUsuario: 'Genera el plan ahora.',
        systemPrompt: _buildWorkoutSystemPrompt(),
        maxTokens: 6000,
      );

      debugPrint('=== RESPUESTA IA (primeros 500 chars): ${respuesta.substring(0, min(500, respuesta.length))}');
      debugPrint('=== PARSEANDO JSON ===');

      final cleanJson = _extraerJson(respuesta);

      WorkoutPlan plan;
      try {
        plan = WorkoutPlan.fromJson(
            jsonDecode(cleanJson) as Map<String, dynamic>);
        debugPrint('=== PLAN GENERADO: ${plan.semana.length} días ===');
      } catch (e) {
        debugPrint('Error parseando plan: $e');
        debugPrint('JSON recibido: $cleanJson');
        _error = 'Error al procesar el plan. Inténtalo de nuevo.';
        return;
      }

      _planEntrenamiento = plan;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyWorkoutPlan, jsonEncode(plan.toJson()));

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          await _firestoreService.guardarPlanEntrenamiento(plan, uid);
        } catch (e) {
          debugPrint('HomeProvider: error guardando entreno en Firestore: $e');
        }
      }
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
      debugPrint('=== GENERANDO PLAN NUTRICIONAL ===');
      final systemPrompt = _buildNutritionSystemPrompt();
      debugPrint('=== SYSTEM PROMPT NUTRICIÓN (primeros 300 chars): ${systemPrompt.substring(0, min(300, systemPrompt.length))}');

      final respuesta = await _ai.enviarMensaje(
        historial: const [],
        mensajeUsuario: 'Genera un plan nutricional para 7 días donde CADA DÍA tenga comidas completamente diferentes. Usa distintas proteínas, distintos carbohidratos y distintos métodos de cocción cada día. Sigue estrictamente las reglas de variedad del system prompt.',
        systemPrompt: systemPrompt,
        maxTokens: 8000,
        temperature: 0,
      );

      debugPrint('=== RESPUESTA IA NUTRICIÓN (primeros 500 chars): ${respuesta.substring(0, min(500, respuesta.length))}');

      final cleanJson = _extraerJson(respuesta);

      debugPrint('=== JSON LIMPIO NUTRICIÓN COMPLETO: $cleanJson');

      MealPlan plan;
      try {
        plan = MealPlan.fromJson(
            jsonDecode(cleanJson) as Map<String, dynamic>);
        debugPrint('=== PLAN NUTRICIONAL GENERADO: ${plan.comidas.length} comidas ===');
        for (final c in plan.comidas) {
          debugPrint('  · ${c.tipo} — ${c.nombre} — ${c.calorias} kcal');
        }
      } catch (e, stackTrace) {
        debugPrint('=== ERROR PARSEANDO NUTRICIÓN: $e');
        debugPrint('=== STACK: $stackTrace');
        debugPrint('=== JSON RECIBIDO COMPLETO: $cleanJson');
        _error = 'Error al procesar el plan nutricional. Inténtalo de nuevo.';
        return;
      }

      _planNutricion = plan;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyMealPlan, jsonEncode(plan.toJson()));

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          await _firestoreService.guardarPlanNutricion(plan, uid);
        } catch (e) {
          debugPrint('HomeProvider: error guardando nutricion en Firestore: $e');
        }
      }
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

  // Sincroniza el plan de nutrición cuando ChatProvider lo modifica
  void sincronizarNutricion(MealPlan? plan) {
    if (plan == null) return;
    _planNutricion = plan;
    notifyListeners();
  }

  // Sincroniza el plan de entrenamiento cuando ChatProvider lo modifica
  void sincronizarEntrenamiento(WorkoutPlan? plan) {
    if (plan == null) return;
    _planEntrenamiento = plan;
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

  // ─── Lista de la compra ─────────────────────────────────────

  Future<void> generarListaCompra() async {
    if (_generandoLista) return;

    if (_planNutricion == null) {
      debugPrint('=== NO HAY PLAN NUTRICIONAL ===');
      _error = 'Primero genera tu plan nutricional';
      notifyListeners();
      return;
    }

    _generandoLista = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('=== GENERANDO LISTA COMPRA ===');
      debugPrint('=== PLAN: ${_planNutricion!.dias.length} días, ${_planNutricion!.comidas.length} comidas ===');

      // Extrae ingredientes de dias primero, luego fallback a comidas planas
      final todosIngredientes = <String>[];
      if (_planNutricion!.dias.isNotEmpty) {
        for (final dia in _planNutricion!.dias) {
          for (final comida in dia.comidas) {
            todosIngredientes.addAll(comida.ingredientes);
          }
        }
      } else {
        for (final comida in _planNutricion!.comidas) {
          todosIngredientes.addAll(comida.ingredientes);
        }
      }

      debugPrint('=== INGREDIENTES EXTRAÍDOS: ${todosIngredientes.length} ===');

      if (todosIngredientes.isEmpty) {
        _error = 'No se encontraron ingredientes en el plan';
        _generandoLista = false;
        notifyListeners();
        return;
      }

      // Deduplica y limita para no sobrepasar el límite de tokens
      final ingredientesLimpios = todosIngredientes
          .map((i) => i.trim().toLowerCase())
          .where((i) => i.isNotEmpty)
          .toSet()
          .toList();
      final ingredientesParaIA = ingredientesLimpios.take(80).toList();

      debugPrint('=== INGREDIENTES ÚNICOS: ${ingredientesLimpios.length} ===');
      debugPrint('=== ENVIANDO A IA: ${ingredientesParaIA.length} ===');

      final prompt = '''Agrupa estos ingredientes por categorías para una lista de la compra semanal. Suma cantidades repetidas.

${ingredientesParaIA.join(', ')}

JSON de respuesta (sin texto extra):
{"items":[{"nombre":"...","cantidad":"...","categoria":"..."}]}

Categorías: Proteínas, Lácteos y huevos, Cereales, Frutas, Verduras, Legumbres, Grasas, Suplementos, Otros''';

      final respuesta = await _ai
          .enviarMensaje(
            historial: const [],
            mensajeUsuario: prompt,
            systemPrompt:
                'Eres un asistente de nutrición. Responde ÚNICAMENTE con JSON válido sin texto adicional ni markdown.',
            maxTokens: 4000,
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('=== RESPUESTA LISTA (primeros 200 chars): ${respuesta.substring(0, respuesta.length.clamp(0, 200))} ===');

      final jsonStr = _extraerJson(respuesta);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      _listaCompra = (data['items'] as List<dynamic>)
          .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
          .toList();

      debugPrint('=== LISTA GENERADA: ${_listaCompra.length} items ===');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _keyListaCompra,
          jsonEncode(_listaCompra.map((i) => i.toJson()).toList()));
    } catch (e, stack) {
      debugPrint('=== ERROR LISTA COMPRA: $e ===');
      debugPrint('=== STACK: $stack ===');
      _error = 'Error al generar la lista. Inténtalo de nuevo.';
    } finally {
      _generandoLista = false;
      notifyListeners();
    }
  }

  void toggleItemComprado(int index) {
    if (index < 0 || index >= _listaCompra.length) return;
    _listaCompra = List.of(_listaCompra);
    _listaCompra[index] =
        _listaCompra[index].copyWith(comprado: !_listaCompra[index].comprado);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(
          _keyListaCompra,
          jsonEncode(_listaCompra.map((i) => i.toJson()).toList()));
    });
    notifyListeners();
  }

  // ─── Registro de peso ────────────────────────────────────────

  Future<void> _cargarPesosInterno(String uid) async {
    try {
      _registrosPeso =
          await _firestoreService.cargarPesos(uid);
      notifyListeners();
    } catch (e) {
      debugPrint('HomeProvider: error cargando pesos: $e');
    }
  }

  Future<void> cargarPesos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _cargandoPesos = true;
    notifyListeners();
    try {
      _registrosPeso = await _firestoreService.cargarPesos(uid);
    } catch (e) {
      debugPrint('HomeProvider: error cargando pesos: $e');
    } finally {
      _cargandoPesos = false;
      notifyListeners();
    }
  }

  Future<void> registrarPeso(double peso, String notas) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final log = WeightLog(
      fecha: DateTime.now(),
      peso: peso,
      notas: notas,
    );
    try {
      await _firestoreService.guardarPeso(uid, log);
      _registrosPeso = [..._registrosPeso, log]
        ..sort((a, b) => a.fecha.compareTo(b.fecha));
      notifyListeners();
    } catch (e) {
      debugPrint('HomeProvider: error guardando peso: $e');
    }
  }

  Future<void> actualizarObjetivosMacros({
    required int proteinas,
    required int carbos,
    required int grasas,
  }) async {
    if (_planNutricion == null) return;
    final cals = proteinas * 4 + carbos * 4 + grasas * 9;
    _planNutricion = MealPlan(
      comidas: _planNutricion!.comidas,
      caloriasObjetivo: cals,
      proteinasObjetivo: proteinas.toDouble(),
      carbosObjetivo: carbos.toDouble(),
      grasasObjetivo: grasas.toDouble(),
      fechaGeneracion: _planNutricion!.fechaGeneracion,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMealPlan, jsonEncode(_planNutricion!.toJson()));

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestoreService.guardarPlanNutricion(_planNutricion!, uid);
      } catch (e) {
        debugPrint('HomeProvider: error guardando macros en Firestore: $e');
      }
    }
    notifyListeners();
    await generarPlanNutricion();
  }

  // ─── Helpers privados ──────────────────────────────────────

  String _buildWorkoutSystemPrompt() {
    final p = _perfil!;
    return '''Eres un preparador físico de élite con doctorado en Ciencias del Deporte y 20 años de experiencia en rendimiento deportivo. Genera planes de entrenamiento basados en periodización científica y fisiología del ejercicio.

PERFIL DEL ATLETA:
Nombre: ${p.nombre} | Edad: ${p.edad} años | Sexo: ${p.sexo}
Peso: ${p.peso} kg | Altura: ${p.altura} cm
Deportes: ${p.deportes.join(', ')}
Objetivo: ${p.objetivo}
Días de entrenamiento: ${p.diasEntrenamiento}/semana | Duración sesión: ${p.minutosSesion} min
Lugar habitual: ${p.lugarEntrenamiento}
Lesiones/restricciones: ${p.lesiones.isEmpty ? 'Ninguna' : p.lesiones}
Suplementos: ${p.suplementosActuales.isEmpty ? 'Ninguno' : p.suplementosActuales.join(', ')}

PRINCIPIOS QUE DEBES APLICAR:
1. PERIODIZACIÓN SEMANAL: Distribuye Alta/Media/Baja intensidad. Nunca 2 sesiones de alta intensidad consecutivas. Post-alta intensidad debe ser baja o descanso.
2. ESPECIFICIDAD DEPORTIVA:
   - Natación: técnica de estilos, series de velocidad (25-50m), series de resistencia (200-400m), trabajo de patada y brazada
   - Fútbol/deportes de equipo: sprints cortos (10-30m), cambios de dirección, resistencia aeróbica intermitente, potencia
   - Running: rodaje suave Z2, intervalos (400m-1km), tempo run, fartlek, tirada larga progresiva
   - Ciclismo: rodaje base Z2, sweet spot 88-93% FTP, bloques VO2max, sprints neuromusculares
   - Artes marciales/boxeo: rounds trabajo/descanso (3min/1min), work capacity, potencia explosiva
   - Gimnasio: RIR system, hipertrofia 8-12 reps @RIR2, fuerza 3-6 @RIR1, resistencia muscular 15-20 @RIR3
3. COMPLEMENTARIEDAD GIMNASIO-DEPORTE: Gym trabaja músculos antagonistas/complementarios al deporte. NUNCA el mismo grupo muscular principal el día previo al deporte principal.
4. TEMPO Y RIR: En fuerza, usa formato "NxN @RIRN" en el campo "series". Ej: "4x8 @RIR2 | tempo 2-0-2 | descanso 90s".
5. GESTIÓN DE LESIONES: Con lesiones activas, sustituye movimientos contraindicados por alternativas seguras. Menciona explícitamente la adaptación.
6. PROGRESIÓN: En "consejo", explica cómo progresar la semana siguiente (más peso, menos RIR, más volumen).

FORMATO JSON — Responde SOLO con este JSON válido:
{"semana":[{"tipo":"deporte|gimnasio|descanso","titulo":"...","descripcion":"...","duracion":60,"lugar":"...","ejercicios":[{"nombre":"...","series":"4x8 @RIR2 | tempo 2-0-2 | descanso 90s","duracion":null,"distancia":null}],"porQueHoy":"...","objetivos":["...","...","..."],"consejo":"...","caracteristicas":["...","...","..."],"completado":false}],"notaDistribucion":"..."}

REGLAS CRÍTICAS:
- Exactamente 7 días: índice 0=Lunes, 1=Martes, 2=Miércoles, 3=Jueves, 4=Viernes, 5=Sábado, 6=Domingo
- Exactamente ${p.diasEntrenamiento} días activos + ${7 - p.diasEntrenamiento} días de descanso/recuperación
- Fuerza: "series" con texto descriptivo incluyendo RIR, "duracion":null, "distancia":null
- Cardio/deporte: "series" descriptivo, usa "duracion" en minutos o "distancia" en metros/km
- Responde ÚNICO bloque JSON sin ningún texto adicional''';
  }

  String _buildNutritionSystemPrompt() {
    final p = _perfil!;
    final int cals;
    final int proteinas;
    final int carbos;
    final int grasas;
    if (_planNutricion != null) {
      cals = _planNutricion!.caloriasObjetivo;
      proteinas = _planNutricion!.proteinasObjetivo.round();
      carbos = _planNutricion!.carbosObjetivo.round();
      grasas = _planNutricion!.grasasObjetivo.round();
    } else {
      cals = caloriasObjetivo;
      proteinas = ((cals * 0.30) / 4).round();
      carbos = ((cals * 0.45) / 4).round();
      grasas = ((cals * 0.25) / 9).round();
    }
    return '''Eres un nutricionista deportivo de élite especializado en periodización nutricional y fisiología del rendimiento. Diseña planes nutricionales científicos basados en el perfil y objetivos del atleta.

REGLA NÚMERO 1 — VARIEDAD ABSOLUTA:
Cada día de la semana DEBE tener comidas completamente diferentes. Está PROHIBIDO repetir el mismo plato en dos días distintos.

VERIFICACIÓN OBLIGATORIA antes de responder:
- Lunes desayuno ≠ Martes desayuno ≠ Miércoles desayuno ≠ Jueves... ≠ Viernes... ≠ Sábado... ≠ Domingo
- Lunes almuerzo ≠ Martes almuerzo ≠ Miércoles almuerzo ≠ ... (todos distintos)
- Lunes cena ≠ Martes cena ≠ Miércoles cena ≠ ... (todos distintos)
- Usar mínimo 5 proteínas distintas en la semana (pollo, huevo, pescado, legumbres, pavo, ternera, marisco...)
- Usar mínimo 4 carbohidratos distintos (arroz, pasta, avena, pan, boniato, quinoa, legumbres, patata...)
- Usar mínimo 3 métodos de cocción distintos (plancha, horno, vapor, crudo, salteado, pochado...)
- Usar mínimo 2 patrones culturales distintos (mediterráneo, asiático, mexicano, nórdico...)

EJEMPLO DE VARIEDAD CORRECTA:

Desayunos (todos distintos):
Lunes: Avena con yogur griego, plátano y nueces
Martes: Tortilla de 3 huevos con espinacas y tomate
Miércoles: Pan de centeno con queso cottage y aguacate
Jueves: Smoothie proteico con avena, fresas y almendras
Viernes: Yogur griego con granola casera y arándanos
Sábado: Tostadas integrales con sardinas y pimiento
Domingo: Gachas de avena con canela, miel y pistachos

Almuerzos (todos distintos):
Lunes: Pollo a la plancha con arroz integral y brócoli
Martes: Lentejas estofadas con verduras y pan integral
Miércoles: Salmón al horno con boniato y judías verdes
Jueves: Pasta integral con atún, tomate y aceitunas
Viernes: Ensalada de garbanzos con pavo y aguacate
Sábado: Arroz con pollo al curry y espinacas salteadas
Domingo: Merluza al vapor con quinoa y pimiento asado

Cenas (todas distintas):
Lunes: Revuelto de claras con champiñones y tostada
Martes: Pechuga de pavo a la plancha con ensalada verde
Miércoles: Sopa de verduras con huevo pochado
Jueves: Tortilla de patata ligera con ensalada verde
Viernes: Bacalao al horno con brócoli y patata
Sábado: Bol de yogur griego con frutos secos y miel
Domingo: Crema de calabaza con pollo desmenuzado

PROHIBIDO:
- El mismo plato en dos días diferentes
- El mismo desayuno más de una vez por semana
- Más de 2 comidas con el mismo tipo de proteína en el mismo día

PERFIL DEL ATLETA:
Nombre: ${p.nombre} | Edad: ${p.edad} años | Sexo: ${p.sexo}
Peso: ${p.peso} kg | Altura: ${p.altura} cm
Objetivo: ${p.objetivo}
Deportes: ${p.deportes.join(', ')} | Días entrenamiento: ${p.diasEntrenamiento}/semana
Tipo de dieta: ${p.tipoDieta}
Alergias/intolerancias: ${p.alergias.isEmpty ? 'Ninguna' : p.alergias.join(', ')}
Presupuesto semanal: ${p.presupuestoSemanal}€
Suplementos activos: ${p.suplementosActuales.isEmpty ? 'Ninguno' : p.suplementosActuales.join(', ')}

OBJETIVOS NUTRICIONALES:
Calorías: $cals kcal/día
Proteínas: ${proteinas}g | Carbohidratos: ${carbos}g | Grasas: ${grasas}g

PRINCIPIOS DE NUTRICIÓN DEPORTIVA:
1. TIMING DE NUTRIENTES: Pre-entreno (1-2h antes): carbos medio-bajo IG + proteína moderada. Post-entreno (dentro de 60min): 20-40g proteína de alta biodisponibilidad + carbos alto IG para reposición de glucógeno.
2. DISTRIBUCIÓN PROTEICA: Distribuye proteína en todas las tomas (umbral leucina: >2-3g/toma). Prioriza fuentes completas: huevo, pollo, pescado, lácteos, legumbres + cereal combinado.
3. CARBOHIDRATOS: Mayor carga peri-entrenamiento. Para pérdida de peso: carbos principalmente en torno al entreno. Para ganancia muscular: distribución más uniforme.
4. CALIDAD DE GRASAS: Incluye omega-3 (salmón, sardinas, nueces, chía), monoinsaturadas (aguacate, aceite de oliva). Limita grasas saturadas.
5. VARIEDAD: Cada comida usa diferente fuente proteica principal y diferente base de carbohidratos. Sin platos repetidos.
6. MICRONUTRIENTES: Verduras y/o frutas variadas en al menos 3 comidas para cubrir vitaminas, minerales y fibra.
7. PRESUPUESTO: Con ${p.presupuestoSemanal}€/semana, prioriza proteínas económicas (huevo, legumbres, pollo, atún en lata) si el presupuesto es ajustado.

VERIFICACIÓN DE VARIEDAD OBLIGATORIA:
Antes de generar el JSON, verifica mentalmente:
- ¿Cada comida usa una fuente proteica distinta (pollo, huevo, pescado, legumbre, lácteos...)?
- ¿Se usan al menos 3 métodos de cocción distintos (plancha, horno, vapor, crudo, salteado)?
- ¿Se incluyen al menos 2 tipos de carbohidratos distintos (arroz, pasta, legumbres, pan, boniato, quinoa)?
- ¿Las verduras varían entre comidas?
Si alguna respuesta es NO, cambia los platos hasta que todas sean SÍ.

EJEMPLOS DE VARIEDAD CORRECTA:
Desayuno: Avena con yogur griego y plátano / Tortilla de 3 huevos con espinacas / Pan integral con aguacate y sardinas
Almuerzo: Pollo a la plancha con arroz integral y brócoli / Lentejas estofadas con verduras / Salmón al horno con boniato
Cena: Merluza al vapor con quinoa y pimiento / Pechuga de pavo con patata y judías verdes / Ensalada de garbanzos con atún
Snack: Yogur griego con nueces / Queso cottage con fruta / Tostada de centeno con mantequilla de cacahuete

FORMATO JSON EXACTO — Responde SOLO con este JSON:
{
  "comidas": [
    {
      "tipo": "desayuno|almuerzo|cena|snack",
      "nombre": "Nombre descriptivo del plato",
      "calorias": 400,
      "proteinas": 30.0,
      "carbohidratos": 45.0,
      "grasas": 12.0,
      "hora": "08:00",
      "ingredientes": ["100g pechuga de pollo", "80g arroz integral", "1 cucharada aceite de oliva"],
      "preparacion": "Instrucciones prácticas en 2-3 pasos concretos",
      "completada": false
    }
  ],
  "caloriasObjetivo": $cals,
  "proteinasObjetivo": $proteinas,
  "carbosObjetivo": $carbos,
  "grasasObjetivo": $grasas
}

REGLAS CRÍTICAS:
- Incluye exactamente: 1 desayuno + 1 almuerzo + 1 cena + 1-2 snacks (total 3-5 comidas)
- Suma de calorías de todas las comidas: entre ${(cals * 0.93).round()} y ${(cals * 1.07).round()} kcal
- Usa "carbohidratos" (no "carbos"), usa "preparacion" (no "receta")
- El array "comidas" va directamente en la raíz del JSON (no dentro de "dias" ni sub-objetos)
- Adapta TODOS los ingredientes a la dieta "${p.tipoDieta}" y evita TODAS las alergias indicadas
- Responde ÚNICO bloque JSON sin texto adicional''';
  }

  String _extraerJson(String texto) {
    String jsonStr = texto.trim();

    if (jsonStr.contains('```json')) {
      jsonStr = jsonStr.split('```json').last.split('```').first.trim();
    } else if (jsonStr.contains('```')) {
      final parts = jsonStr.split('```');
      if (parts.length >= 2) jsonStr = parts[1].trim();
    }

    final startIdx = jsonStr.indexOf('{');
    final endIdx = jsonStr.lastIndexOf('}');
    if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
      jsonStr = jsonStr.substring(startIdx, endIdx + 1);
    }

    return jsonStr;
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
