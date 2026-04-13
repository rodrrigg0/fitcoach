import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/services/firestore_service.dart';

// ─────────────────────────────────────────────────────────────
// Enums y clases del sistema de pasos fijos
// ─────────────────────────────────────────────────────────────

enum TipoPregunta {
  textoLibre,
  opcionUnica,
  opcionMultiple,
  ruedaNumerica,
  deportes,
  siNo,
}

class OnboardingStep {
  final int numero;
  final String categoria;
  final String pregunta;
  final TipoPregunta tipo;
  final List<String>? opciones;
  final int? minValor;
  final int? maxValor;
  final int? stepValor;
  final String? sufijo;

  const OnboardingStep({
    required this.numero,
    required this.categoria,
    required this.pregunta,
    required this.tipo,
    this.opciones,
    this.minValor,
    this.maxValor,
    this.stepValor,
    this.sufijo,
  });
}

// ─────────────────────────────────────────────────────────────
// Provider principal
// ─────────────────────────────────────────────────────────────

class OnboardingProvider extends ChangeNotifier {
  // ── Pasos fijos ───────────────────────────────────────────

  static const List<OnboardingStep> pasos = [
    OnboardingStep(
      numero: 1,
      categoria: 'PERSONAL',
      pregunta: '¿Cuál es tu nombre?',
      tipo: TipoPregunta.textoLibre,
    ),
    OnboardingStep(
      numero: 2,
      categoria: 'PERSONAL',
      pregunta: '¿Cuántos años tienes?',
      tipo: TipoPregunta.ruedaNumerica,
      minValor: 10,
      maxValor: 80,
      stepValor: 1,
      sufijo: 'años',
    ),
    OnboardingStep(
      numero: 3,
      categoria: 'PERSONAL',
      pregunta: '¿Cuál es tu sexo biológico?',
      tipo: TipoPregunta.opcionUnica,
      opciones: ['Hombre', 'Mujer', 'Otro'],
    ),
    OnboardingStep(
      numero: 4,
      categoria: 'PERSONAL',
      pregunta: '¿Cuánto pesas?',
      tipo: TipoPregunta.ruedaNumerica,
      minValor: 30,
      maxValor: 200,
      stepValor: 1,
      sufijo: 'kg',
    ),
    OnboardingStep(
      numero: 5,
      categoria: 'PERSONAL',
      pregunta: '¿Cuánto mides?',
      tipo: TipoPregunta.ruedaNumerica,
      minValor: 100,
      maxValor: 220,
      stepValor: 1,
      sufijo: 'cm',
    ),
    OnboardingStep(
      numero: 6,
      categoria: 'OBJETIVO',
      pregunta: '¿Cuál es tu objetivo principal?',
      tipo: TipoPregunta.opcionUnica,
      opciones: [
        'Perder grasa',
        'Ganar músculo',
        'Recomposición',
        'Rendimiento deportivo',
        'Mantener peso',
        'Salud general',
      ],
    ),
    OnboardingStep(
      numero: 7,
      categoria: 'DEPORTE',
      pregunta: '¿Qué deporte o actividad quieres practicar?',
      tipo: TipoPregunta.deportes,
    ),
    OnboardingStep(
      numero: 8,
      categoria: 'DEPORTE',
      pregunta: '¿Quieres complementar con gimnasio?',
      tipo: TipoPregunta.opcionUnica,
      opciones: [
        'Sí, como complemento',
        'No, solo mi deporte',
        'Ya entreno en gimnasio',
      ],
    ),
    OnboardingStep(
      numero: 9,
      categoria: 'ENTRENAMIENTO',
      pregunta: '¿Cuántos días por semana puedes entrenar?',
      tipo: TipoPregunta.opcionUnica,
      opciones: [
        '2 días',
        '3 días',
        '4 días',
        '5 días',
        '6 días',
        '7 días',
      ],
    ),
    OnboardingStep(
      numero: 10,
      categoria: 'ENTRENAMIENTO',
      pregunta: '¿Cuánto tiempo por sesión?',
      tipo: TipoPregunta.opcionUnica,
      opciones: [
        '30 min',
        '45 min',
        '60 min',
        '90 min',
        'Más de 90 min',
      ],
    ),
    OnboardingStep(
      numero: 11,
      categoria: 'ENTRENAMIENTO',
      pregunta: '¿Tienes alguna lesión o limitación física?',
      tipo: TipoPregunta.siNo,
      opciones: ['No tengo lesiones', 'Sí tengo lesiones'],
    ),
    OnboardingStep(
      numero: 12,
      categoria: 'NUTRICIÓN',
      pregunta: '¿Sigues algún tipo de dieta?',
      tipo: TipoPregunta.opcionUnica,
      opciones: [
        'Omnívoro',
        'Vegetariano',
        'Vegano',
        'Sin gluten',
        'Keto',
        'Sin restricciones',
      ],
    ),
    OnboardingStep(
      numero: 13,
      categoria: 'NUTRICIÓN',
      pregunta: '¿Tienes alergias alimentarias?',
      tipo: TipoPregunta.siNo,
      opciones: ['No tengo alergias', 'Sí tengo alergias'],
    ),
    OnboardingStep(
      numero: 14,
      categoria: 'NUTRICIÓN',
      pregunta: '¿Cuál es tu presupuesto semanal en alimentación?',
      tipo: TipoPregunta.ruedaNumerica,
      minValor: 20,
      maxValor: 300,
      stepValor: 5,
      sufijo: '€',
    ),
    OnboardingStep(
      numero: 15,
      categoria: 'HÁBITOS',
      pregunta: '¿Cuántas horas duermes normalmente?',
      tipo: TipoPregunta.ruedaNumerica,
      minValor: 4,
      maxValor: 12,
      stepValor: 1,
      sufijo: 'h',
    ),
    OnboardingStep(
      numero: 16,
      categoria: 'HÁBITOS',
      pregunta: '¿Tomas algún suplemento actualmente?',
      tipo: TipoPregunta.opcionMultiple,
      opciones: [
        'Ninguno',
        'Proteína whey',
        'Creatina',
        'BCAA',
        'Cafeína',
        'Vitamina D',
        'Omega 3',
        'Magnesio',
        'Multivitamínico',
        'Pre-entreno',
        'Glutamina',
        'ZMA',
        'Colágeno',
        'Otro',
      ],
    ),
  ];

  // ── Estado interno ────────────────────────────────────────

  int _pasoActual = 0;

  // Datos recogidos
  String _nombre = '';
  int _edad = 25;
  String _sexo = '';
  double _peso = 70;
  double _altura = 170;
  String _objetivo = '';
  List<String> _deportes = [];
  String _complementoGimnasio = '';
  int _dias = 3;
  int _minutos = 60;
  String _lesiones = 'Ninguna';
  String _tipoDieta = '';
  String _alergias = 'Ninguna';
  int _presupuesto = 80;
  int _horasSueno = 7;
  List<String> _suplementos = [];

  UserProfile _perfilEnConstruccion = UserProfile.vacio();
  bool _onboardingCompletado = false;

  Set<String> _partesIluminadas = {};
  Map<String, String> _statsVisibles = {
    'nombre': '...',
    'objetivo': '...',
    'deporte': '...',
    'lugar': '...',
    'dias': '...',
    'peso': '...',
    'altura': '...',
    'edad': '...',
  };

  // ── Getters públicos ──────────────────────────────────────

  int get pasoActual => _pasoActual;
  OnboardingStep get stepActual => pasos[_pasoActual];
  UserProfile get perfilEnConstruccion => _perfilEnConstruccion;
  bool get onboardingCompletado => _onboardingCompletado;
  Set<String> get partesIluminadas => Set.unmodifiable(_partesIluminadas);
  Map<String, String> get statsVisibles => Map.unmodifiable(_statsVisibles);

  // ── Ciclo de vida ─────────────────────────────────────────

  void iniciarOnboarding() {
    _pasoActual = 0;
    _perfilEnConstruccion = UserProfile.vacio();
    _onboardingCompletado = false;
    _partesIluminadas = {};
    _statsVisibles = {
      'nombre': '...',
      'objetivo': '...',
      'deporte': '...',
      'lugar': '...',
      'dias': '...',
      'peso': '...',
      'altura': '...',
      'edad': '...',
    };
    _nombre = '';
    _edad = 25;
    _sexo = '';
    _peso = 70;
    _altura = 170;
    _objetivo = '';
    _deportes = [];
    _complementoGimnasio = '';
    _dias = 3;
    _minutos = 60;
    _lesiones = 'Ninguna';
    _tipoDieta = '';
    _alergias = 'Ninguna';
    _presupuesto = 80;
    _horasSueno = 7;
    _suplementos = [];
    notifyListeners();
  }

  // ── Flujo principal ───────────────────────────────────────

  Future<void> avanzarPaso(String valorRespuesta) async {
    final numeroPaso = _pasoActual + 1;
    _guardarRespuesta(numeroPaso, valorRespuesta);
    _aplicarStats(numeroPaso, valorRespuesta);

    if (_pasoActual < pasos.length - 1) {
      _pasoActual++;
      notifyListeners();
    } else {
      await _generarPerfilCompleto();
    }
  }

  void _guardarRespuesta(int numeroPaso, String valor) {
    switch (numeroPaso) {
      case 1:
        _nombre = _capitalizarNombre(valor);
        break;
      case 2:
        _edad = int.tryParse(valor) ?? 25;
        break;
      case 3:
        _sexo = valor;
        break;
      case 4:
        _peso = double.tryParse(valor) ?? 70;
        break;
      case 5:
        _altura = double.tryParse(valor) ?? 170;
        break;
      case 6:
        _objetivo = _mapObjetivo(valor);
        break;
      case 7:
        _deportes = valor.split(', ').where((s) => s.isNotEmpty).toList();
        break;
      case 8:
        _complementoGimnasio = valor;
        break;
      case 9:
        _dias = int.tryParse(valor.split(' ').first) ?? 3;
        break;
      case 10:
        _minutos = _mapMinutos(valor);
        break;
      case 11:
        _lesiones = valor;
        break;
      case 12:
        _tipoDieta = valor;
        break;
      case 13:
        _alergias = valor;
        break;
      case 14:
        _presupuesto = int.tryParse(valor) ?? 80;
        break;
      case 15:
        _horasSueno = int.tryParse(valor) ?? 7;
        break;
      case 16:
        _suplementos =
            valor.split(', ').where((s) => s.isNotEmpty).toList();
        if (_suplementos.contains('Ninguno')) _suplementos = [];
        break;
    }
  }

  void _aplicarStats(int numeroPaso, String valor) {
    switch (numeroPaso) {
      case 1:
        _statsVisibles['nombre'] = _capitalizarNombre(valor);
        break;
      case 2:
        _statsVisibles['edad'] = '$valor años';
        break;
      case 4:
        _statsVisibles['peso'] = '$valor kg';
        break;
      case 5:
        _statsVisibles['altura'] = '$valor cm';
        break;
      case 6:
        _statsVisibles['objetivo'] = valor;
        break;
      case 7:
        _statsVisibles['deporte'] =
            valor.split(', ').where((s) => s.isNotEmpty).first;
        _actualizarLugarPorDeporte(valor);
        _actualizarPartesIluminadas(valor);
        break;
      case 9:
        _statsVisibles['dias'] = '${valor.split(' ').first}/sem';
        break;
      default:
        break;
    }
  }

  void _actualizarLugarPorDeporte(String deporte) {
    final d = deporte.toLowerCase();
    final String lugar;
    if (d.contains('natación') ||
        d.contains('natacion') ||
        d.contains('waterpolo') ||
        d.contains('nadar')) {
      lugar = 'Piscina';
    } else if (d.contains('running') ||
        d.contains('atletismo') ||
        d.contains('ciclismo') ||
        d.contains('fútbol') ||
        d.contains('futbol') ||
        d.contains('senderismo') ||
        d.contains('trekking') ||
        d.contains('rugby') ||
        d.contains('volleyball') ||
        d.contains('voleibol')) {
      lugar = 'Exterior';
    } else if (d.contains('gimnasio') ||
        d.contains('crossfit') ||
        d.contains('boxeo') ||
        d.contains('artes marciales') ||
        d.contains('judo') ||
        d.contains('karate')) {
      lugar = 'Gimnasio';
    } else if (d.contains('yoga') || d.contains('pilates')) {
      lugar = 'Casa/Gimnasio';
    } else if (d.contains('pádel') ||
        d.contains('padel') ||
        d.contains('tenis') ||
        d.contains('squash')) {
      lugar = 'Pista';
    } else if (d.contains('escalada') || d.contains('climbing')) {
      lugar = 'Rocódromo';
    } else if (d.contains('surf') ||
        d.contains('esquí') ||
        d.contains('esqui')) {
      lugar = 'Exterior';
    } else {
      lugar = 'Exterior';
    }
    _statsVisibles['lugar'] = lugar;
  }

  void _actualizarPartesIluminadas(String deporte) {
    final d = deporte.toLowerCase();
    if (d.contains('gimnasio') ||
        d.contains('crossfit') ||
        d.contains('boxeo') ||
        d.contains('musculación') ||
        d.contains('musculacion') ||
        d.contains('calistenia')) {
      _partesIluminadas.addAll(['brazos', 'torso']);
    }
    if (d.contains('running') ||
        d.contains('fútbol') ||
        d.contains('futbol') ||
        d.contains('ciclismo') ||
        d.contains('tenis') ||
        d.contains('pádel') ||
        d.contains('padel') ||
        d.contains('senderismo') ||
        d.contains('atletismo')) {
      _partesIluminadas.add('piernas');
    }
    if (d.contains('natación') ||
        d.contains('natacion') ||
        d.contains('surf') ||
        d.contains('remo') ||
        d.contains('waterpolo')) {
      _partesIluminadas.addAll(['brazos', 'torso', 'piernas']);
    }
    if (d.contains('yoga') || d.contains('pilates')) {
      _partesIluminadas.addAll(['torso', 'piernas']);
    }
  }

  // ── Generar perfil completo ───────────────────────────────

  Future<void> _generarPerfilCompleto() async {
    final deportesFinal = List<String>.from(_deportes);
    if (_complementoGimnasio.contains('complemento') &&
        !deportesFinal.any((d) => d.toLowerCase().contains('gimnasio'))) {
      deportesFinal.add('Gimnasio');
    }
    if (_complementoGimnasio.contains('Ya entreno') &&
        !deportesFinal.any((d) => d.toLowerCase().contains('gimnasio'))) {
      deportesFinal.add('Gimnasio');
    }

    final alergiasLista =
        _alergias.startsWith('No') ? <String>[] : [_alergias];
    final suplementosLista = List<String>.from(_suplementos);

    _perfilEnConstruccion = UserProfile(
      id: const Uuid().v4(),
      nombre: _nombre,
      edad: _edad,
      sexo: _sexo,
      peso: _peso,
      altura: _altura,
      objetivo: _objetivo,
      nivelActividad: _inferirNivelActividad(_dias),
      deportes: deportesFinal,
      diasEntrenamiento: _dias,
      minutosSesion: _minutos,
      lugarEntrenamiento: _statsVisibles['lugar'] ?? '',
      lesiones: _lesiones,
      tipoDieta: _tipoDieta,
      alergias: alergiasLista,
      presupuestoSemanal: _presupuesto,
      horasSueno: _horasSueno,
      suplementosActuales: suplementosLista,
      onboardingCompletado: true,
      fechaRegistro: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'user_profile', jsonEncode(_perfilEnConstruccion.toJson()));
    await prefs.setBool('onboarding_completado', true);

    _onboardingCompletado = true;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirestoreService()
            .guardarPerfil(_perfilEnConstruccion, uid)
            .timeout(const Duration(seconds: 8));
      }
    } catch (_) {}
  }

  // ── Helpers estáticos ─────────────────────────────────────

  static String _capitalizarNombre(String nombre) {
    return nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  static String _mapObjetivo(String valor) {
    const map = {
      'Perder grasa': 'perder_grasa',
      'Ganar músculo': 'ganar_musculo',
      'Recomposición': 'recomposicion',
      'Rendimiento deportivo': 'rendimiento',
      'Mantener peso': 'mantener',
      'Salud general': 'salud',
    };
    return map[valor] ?? valor.toLowerCase().replaceAll(' ', '_');
  }

  static String _inferirNivelActividad(int dias) {
    if (dias <= 2) return 'sedentario';
    if (dias <= 3) return 'ligero';
    if (dias <= 4) return 'moderado';
    if (dias <= 5) return 'activo';
    return 'muy_activo';
  }

  static int _mapMinutos(String valor) {
    if (valor.contains('30')) return 30;
    if (valor.contains('45')) return 45;
    if (valor.contains('60')) return 60;
    if (valor.contains('90') && !valor.contains('Más')) return 90;
    return 120;
  }
}
