import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:fitcoach/data/models/daily_checkin.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/models/workout_plan.dart';
import 'package:fitcoach/data/services/ai_service.dart';
import 'package:fitcoach/data/services/firestore_service.dart';

class DailyCheckinProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final AIService _ai = AIService();

  WorkoutPlan? _plan;
  UserProfile? _perfil;

  DailyCheckin? checkinHoy;
  bool cargando = false;
  bool enviandoRespuesta = false;
  bool checkinCompletado = false;
  List<WeeklySummary> informesSemanales = [];

  bool get esDiaEntreno {
    if (_plan == null) return false;
    final idx = DateTime.now().weekday - 1;
    if (idx >= _plan!.semana.length) return false;
    return !_plan!.semana[idx].esDescanso;
  }

  bool get esFinDeSemana => DateTime.now().weekday == DateTime.sunday;

  void actualizarContexto(WorkoutPlan? plan, UserProfile? perfil) {
    _plan = plan;
    _perfil = perfil;
  }

  Future<void> inicializar() async {
    cargando = true;
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      cargando = false;
      notifyListeners();
      return;
    }

    try {
      checkinHoy = await _firestore.cargarCheckinHoy(uid);
      checkinCompletado = checkinHoy?.respuestaEntrenador != null;
    } catch (e) {
      debugPrint('DailyCheckinProvider: error cargando checkin: $e');
    }

    try {
      informesSemanales = await _firestore.cargarInformesSemanales(uid);
    } catch (e) {
      debugPrint('DailyCheckinProvider: error cargando informes: $e');
      informesSemanales = [];
    }

    cargando = false;
    notifyListeners();
  }

  Future<void> guardarCheckinYPedirRespuesta(DailyCheckin checkin) async {
    enviandoRespuesta = true;
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      enviandoRespuesta = false;
      notifyListeners();
      return;
    }

    try {
      await _firestore.guardarCheckin(uid, checkin);

      final respuesta = await _generarRespuestaEntrenador(checkin);

      final checkinConRespuesta = checkin.copyWith(
        respuestaEntrenador: respuesta,
        fechaRespuesta: DateTime.now(),
      );

      await _firestore.guardarCheckin(uid, checkinConRespuesta);

      checkinHoy = checkinConRespuesta;
      checkinCompletado = true;
    } catch (e) {
      debugPrint('DailyCheckinProvider: error guardando checkin: $e');
      checkinHoy = checkin.copyWith(
        respuestaEntrenador:
            'No se pudo obtener respuesta del entrenador. Inténtalo más tarde.',
        fechaRespuesta: DateTime.now(),
      );
      checkinCompletado = true;
    }

    enviandoRespuesta = false;
    notifyListeners();

    if (esFinDeSemana) {
      _generarInformeSemanal();
    }
  }

  Future<String> _generarRespuestaEntrenador(DailyCheckin checkin) async {
    final planHoy = _plan != null
        ? _plan!.semana[DateTime.now().weekday - 1]
        : null;

    String contexto;
    if (checkin.esDiaEntreno) {
      contexto = '''
Datos del entreno de hoy:
- Energía: ${checkin.nivelEnergia}/10
- Rendimiento: ${checkin.nivelRendimiento}/10
- Dolor/molestias: ${checkin.nivelDolor}/10
- Completó todos los ejercicios: ${checkin.completoTodosEjercicios == true ? 'Sí' : 'No'}
- Modificaciones: ${checkin.ejerciciosModificados?.isNotEmpty == true ? checkin.ejerciciosModificados : 'Ninguna'}
- Notas: ${checkin.notasEntreno?.isNotEmpty == true ? checkin.notasEntreno : 'Ninguna'}
- Comidas: desayuno=${checkin.completoDesayuno == true ? 'Sí' : 'No'}, almuerzo=${checkin.completoAlmuerzo == true ? 'Sí' : 'No'}, cena=${checkin.completoCena == true ? 'Sí' : 'No'}
- Hidratación: ${checkin.vasosDe250ml ?? 0} vasos de 250ml
- Sueño: ${checkin.horasSueno ?? 0}h (calidad ${checkin.calidadSueno ?? 0}/5)
- Pregunta: ${checkin.preguntaEntrenador?.isNotEmpty == true ? checkin.preguntaEntrenador : 'Sin pregunta'}
Entrenamiento de hoy: ${planHoy?.titulo ?? 'No especificado'}''';
    } else {
      contexto = '''
Día de descanso:
- Nivel de recuperación: ${checkin.nivelRecuperacion}/10
- Horas de sueño: ${checkin.horasSueno ?? 0}h
- Calidad del sueño: ${checkin.calidadSueno ?? 0}/5
- Duda o comentario: ${checkin.dudas?.isNotEmpty == true ? checkin.dudas : 'Ninguno'}''';
    }

    final systemPrompt = '''
Eres el entrenador personal de ${_perfil?.nombre ?? 'el atleta'}.
Acabas de recibir el reporte diario del atleta.

PERFIL DEL ATLETA:
Nombre: ${_perfil?.nombre ?? 'Atleta'}
Objetivo: ${_perfil?.objetivo ?? 'No especificado'}
Deporte: ${_perfil?.deportes.join(', ') ?? 'No especificado'}
Peso actual: ${_perfil?.peso ?? 0} kg

$contexto

Responde como un entrenador personal experto y cercano:
1. Evalúa cómo ha ido el día (sé específico con los datos)
2. Destaca lo positivo primero
3. Da 1-2 correcciones o sugerencias concretas
4. Responde su pregunta si la hay
5. Motívalo para el siguiente entrenamiento
6. Si hay señales de sobreentrenamiento (energía <4, dolor >7, sueño <5h varios días), alerta y sugiere ajuste
7. Tono: profesional pero cercano, como un entrenador real
8. Máximo 200 palabras
9. Sin emojis''';

    return await _ai.enviarMensaje(
      historial: [],
      mensajeUsuario: 'Genera la respuesta del entrenador',
      systemPrompt: systemPrompt,
      maxTokens: 512,
    );
  }

  Future<void> _generarInformeSemanal() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    List<DailyCheckin> checkins;
    try {
      checkins = await _firestore.cargarCheckinsSemana(uid);
    } catch (e) {
      return;
    }
    if (checkins.isEmpty) return;

    final sesionesCompletadas = checkins
        .where((c) => c.esDiaEntreno && c.completoTodosEjercicios == true)
        .length;

    final energiaNonNull =
        checkins.where((c) => c.nivelEnergia != null).toList();
    final promedioEnergia = energiaNonNull.isEmpty
        ? 0.0
        : energiaNonNull.map((c) => c.nivelEnergia!).reduce((a, b) => a + b) /
            energiaNonNull.length;

    final suenoNonNull =
        checkins.where((c) => c.horasSueno != null).toList();
    final promedioSueno = suenoNonNull.isEmpty
        ? 0.0
        : suenoNonNull.map((c) => c.horasSueno!).reduce((a, b) => a + b) /
            suenoNonNull.length;

    final rendNonNull =
        checkins.where((c) => c.nivelRendimiento != null).toList();
    final promedioRendimiento = rendNonNull.isEmpty
        ? 0.0
        : rendNonNull
                .map((c) => c.nivelRendimiento!.toDouble())
                .reduce((a, b) => a + b) /
            rendNonNull.length;

    final sesionesPlaneadas = checkins.where((c) => c.esDiaEntreno).length;
    final porcentajeComidas = checkins.isEmpty
        ? 0.0
        : checkins.where((c) => c.completoDesayuno == true).length /
            checkins.length *
            100;

    final systemPrompt = '''
Eres el entrenador personal de ${_perfil?.nombre ?? 'el atleta'}.
Es fin de semana y debes generar el informe semanal de rendimiento.

DATOS DE LA SEMANA:
Sesiones completadas: $sesionesCompletadas de $sesionesPlaneadas
Promedio energía: ${promedioEnergia.toStringAsFixed(1)}/10
Promedio sueño: ${promedioSueno.toStringAsFixed(1)}h
Peso actual: ${_perfil?.peso ?? 0} kg

CHECKINS DETALLADOS:
${checkins.map((c) => '''
${c.diaSemana}: ${c.esDiaEntreno ? 'Entreno' : 'Descanso'}
  Energía: ${c.nivelEnergia ?? 'N/A'}/10  Rendimiento: ${c.nivelRendimiento ?? 'N/A'}/10  Sueño: ${c.horasSueno ?? 'N/A'}h''').join('\n')}

Genera un informe semanal profesional con:
1. RESUMEN EJECUTIVO (2-3 frases)
2. RENDIMIENTO EN ENTRENAMIENTOS
3. NUTRICIÓN Y RECUPERACIÓN
4. PUNTOS FUERTES DE LA SEMANA
5. ÁREAS DE MEJORA (máximo 3)
6. OBJETIVOS PARA LA PRÓXIMA SEMANA (3 objetivos medibles)
7. VALORACIÓN GENERAL (nota del 1-10 con justificación)

Tono: informe profesional, directo, basado en datos, motivador.
Sin emojis. Máximo 400 palabras.''';

    String informe;
    try {
      informe = await _ai.enviarMensaje(
        historial: [],
        mensajeUsuario: 'Genera el informe semanal',
        systemPrompt: systemPrompt,
        maxTokens: 1024,
      );
    } catch (e) {
      return;
    }

    final ahora = DateTime.now();
    final monday =
        ahora.subtract(Duration(days: ahora.weekday - 1));
    final summaryId = DateFormat('yyyy-MM-dd').format(monday);

    final summary = WeeklySummary(
      id: summaryId,
      uid: uid,
      semanaInicio: monday,
      semanaFin: ahora,
      checkins: checkins,
      pesoInicioSemana: _perfil?.peso ?? 0,
      sesionesCompletadas: sesionesCompletadas,
      sesionesPlaneadas: sesionesPlaneadas,
      porcentajeCumplimientoComidas: porcentajeComidas,
      promedioSueno: promedioSueno,
      promedioEnergia: promedioEnergia,
      promedioRendimiento: promedioRendimiento,
      informeIA: informe,
      fechaGeneracion: ahora,
    );

    try {
      await _firestore.guardarInformeSemanal(uid, summary);
    } catch (e) {
      debugPrint('DailyCheckinProvider: error guardando informe: $e');
    }

    informesSemanales.insert(0, summary);
    notifyListeners();
  }
}
