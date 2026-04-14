import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:fitcoach/data/models/exercise_log.dart';
import 'package:fitcoach/data/models/workout_plan.dart';
import 'package:fitcoach/data/services/firestore_service.dart';

class TrainingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<WorkoutLog> _historialSesiones = [];
  WorkoutLog? _sesionActual;
  bool _guardando = false;

  List<WorkoutLog> get historialSesiones => _historialSesiones;
  WorkoutLog? get sesionActual => _sesionActual;
  bool get guardando => _guardando;

  // ─── Sesión ────────────────────────────────────────────────

  Future<void> iniciarSesion(WorkoutDay dia, String diaSemana) async {
    final now = DateTime.now();
    _sesionActual = WorkoutLog(
      id: now.millisecondsSinceEpoch.toString(),
      fecha: now,
      diaSemana: diaSemana,
      tituloEntrenamiento: dia.titulo,
      ejercicios: dia.ejercicios
          .asMap()
          .entries
          .map((entry) => ExerciseLog(
                id: '${entry.value.nombre}_${entry.key}_${now.millisecondsSinceEpoch}',
                ejercicioNombre: entry.value.nombre,
                diaEntrenamiento: diaSemana,
                fecha: now,
                series: [],
                notas: '',
              ))
          .toList(),
      completado: false,
      notas: '',
    );
    notifyListeners();
  }

  // Actualiza series sin rebuild (estado local en la card)
  void actualizarSeriesEjercicio(
      String ejercicioId, List<SerieLog> series) {
    if (_sesionActual == null) return;
    final ejercicios = _sesionActual!.ejercicios
        .map((e) =>
            e.id == ejercicioId ? e.copyWith(series: series) : e)
        .toList();
    _sesionActual = _sesionActual!.copyWith(ejercicios: ejercicios);
  }

  // Actualiza notas de ejercicio sin rebuild
  void actualizarNotasEjercicio(String ejercicioId, String notas) {
    if (_sesionActual == null) return;
    final ejercicios = _sesionActual!.ejercicios
        .map((e) =>
            e.id == ejercicioId ? e.copyWith(notas: notas) : e)
        .toList();
    _sesionActual = _sesionActual!.copyWith(ejercicios: ejercicios);
  }

  // Actualiza notas de sesión sin rebuild
  void actualizarNotasSesion(String notas) {
    if (_sesionActual == null) return;
    _sesionActual = _sesionActual!.copyWith(notas: notas);
  }

  Future<void> guardarSesion() async {
    if (_sesionActual == null) return;
    _guardando = true;
    notifyListeners();

    try {
      _sesionActual = _sesionActual!.copyWith(completado: true);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _firestoreService.guardarWorkoutLog(uid, _sesionActual!);
        _historialSesiones.insert(0, _sesionActual!);
      }
    } catch (e) {
      debugPrint('TrainingProvider: error guardando sesión: $e');
    } finally {
      _guardando = false;
      _sesionActual = null;
      notifyListeners();
    }
  }

  // ─── Historial ─────────────────────────────────────────────

  Future<void> cargarHistorial() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      _historialSesiones = await _firestoreService
          .cargarWorkoutLogs(uid)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('TrainingProvider: error cargando historial: $e');
      _historialSesiones = [];
    }
    notifyListeners();
  }

  // Devuelve el último registro guardado de un ejercicio
  ExerciseLog? ultimoRegistro(String nombre) {
    for (final sesion in _historialSesiones) {
      for (final ejercicio in sesion.ejercicios) {
        if (ejercicio.ejercicioNombre.toLowerCase() ==
            nombre.toLowerCase()) {
          return ejercicio;
        }
      }
    }
    return null;
  }
}
