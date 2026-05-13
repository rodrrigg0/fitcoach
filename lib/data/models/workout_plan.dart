class Exercise {
  final String nombre;
  final String detalle;
  final String duracion;
  final String? notas;
  final String? distancia;

  const Exercise({
    required this.nombre,
    this.detalle = '',
    this.duracion = '',
    this.notas,
    this.distancia,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final detalle = json['detalle']?.toString()
        ?? json['series']?.toString()
        ?? '';

    final durVal = json['duracion'];
    String duracion = '';
    if (durVal != null) {
      final s = durVal.toString();
      duracion = int.tryParse(s) != null ? '$s min' : s;
    }

    return Exercise(
      nombre: json['nombre']?.toString() ?? '',
      detalle: detalle,
      duracion: duracion,
      notas: json['notas']?.toString(),
      distancia: json['distancia']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        if (detalle.isNotEmpty) 'detalle': detalle,
        if (duracion.isNotEmpty) 'duracion': duracion,
        if (notas != null) 'notas': notas,
        if (distancia != null) 'distancia': distancia,
      };
}

class WorkoutDay {
  final String tipo; // 'deporte' | 'gimnasio' | 'descanso'
  final String titulo;
  final String descripcion;
  final int duracion;
  final String lugar;
  final List<Exercise> ejercicios;
  final String porQueHoy;
  final List<String> objetivos;
  final String consejo;
  final List<String> caracteristicas;
  bool completado;

  WorkoutDay({
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.duracion,
    required this.lugar,
    required this.ejercicios,
    required this.porQueHoy,
    required this.objetivos,
    required this.consejo,
    required this.caracteristicas,
    this.completado = false,
  });

  bool get esDescanso => tipo == 'descanso';

  factory WorkoutDay.fromJson(Map<String, dynamic> json) => WorkoutDay(
        tipo: json['tipo']?.toString() ?? 'descanso',
        titulo: json['titulo']?.toString() ?? '',
        descripcion: json['descripcion']?.toString() ?? '',
        duracion: json['duracion'] != null
            ? int.tryParse(json['duracion'].toString()) ?? 0
            : 0,
        lugar: json['lugar']?.toString() ?? '',
        ejercicios: (json['ejercicios'] as List<dynamic>?)
                ?.map((e) =>
                    Exercise.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        porQueHoy: json['porQueHoy']?.toString() ?? '',
        objetivos: (json['objetivos'] as List<dynamic>?)
                ?.map((e) => e?.toString() ?? '')
                .toList() ??
            [],
        consejo: json['consejo']?.toString() ?? '',
        caracteristicas: (json['caracteristicas'] as List<dynamic>?)
                ?.map((e) => e?.toString() ?? '')
                .toList() ??
            [],
        completado: json['completado'] == true,
      );

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        'titulo': titulo,
        'descripcion': descripcion,
        'duracion': duracion,
        'lugar': lugar,
        'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
        'porQueHoy': porQueHoy,
        'objetivos': objetivos,
        'consejo': consejo,
        'caracteristicas': caracteristicas,
        'completado': completado,
      };

  WorkoutDay copyWith({
    String? tipo,
    String? titulo,
    String? descripcion,
    int? duracion,
    String? lugar,
    List<Exercise>? ejercicios,
    String? porQueHoy,
    List<String>? objetivos,
    String? consejo,
    List<String>? caracteristicas,
    bool? completado,
  }) =>
      WorkoutDay(
        tipo: tipo ?? this.tipo,
        titulo: titulo ?? this.titulo,
        descripcion: descripcion ?? this.descripcion,
        duracion: duracion ?? this.duracion,
        lugar: lugar ?? this.lugar,
        ejercicios: ejercicios ?? this.ejercicios,
        porQueHoy: porQueHoy ?? this.porQueHoy,
        objetivos: objetivos ?? this.objetivos,
        consejo: consejo ?? this.consejo,
        caracteristicas: caracteristicas ?? this.caracteristicas,
        completado: completado ?? this.completado,
      );

  static WorkoutDay descanso() => WorkoutDay(
        tipo: 'descanso',
        titulo: 'Día de recuperación',
        descripcion: 'El descanso es parte del entrenamiento',
        duracion: 0,
        lugar: '',
        ejercicios: [],
        porQueHoy:
            'El descanso activo permite que tus músculos se recuperen y adapten al entrenamiento.',
        objetivos: [
          'Recuperación muscular',
          'Hidratación óptima',
          'Descanso mental',
        ],
        consejo:
            'Aprovecha para hidratarte bien, estirarte suavemente y dormir al menos 8 horas.',
        caracteristicas: ['Descanso', 'Recuperación'],
      );
}

class WorkoutPlan {
  final List<WorkoutDay> semana; // 7 días: índice 0=Lunes, 6=Domingo
  final String notaDistribucion;
  final DateTime fechaGeneracion;

  const WorkoutPlan({
    required this.semana,
    required this.notaDistribucion,
    required this.fechaGeneracion,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    final rawSemana = json['semana'] as List<dynamic>? ?? [];
    final semana = rawSemana
        .map((d) => WorkoutDay.fromJson(d as Map<String, dynamic>))
        .toList();
    while (semana.length < 7) {
      semana.add(WorkoutDay.descanso());
    }
    return WorkoutPlan(
      semana: semana.take(7).toList(),
      notaDistribucion: json['notaDistribucion']?.toString() ?? '',
      fechaGeneracion: json['fechaGeneracion'] != null
          ? DateTime.tryParse(json['fechaGeneracion'].toString()) ??
              DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'semana': semana.map((d) => d.toJson()).toList(),
        'notaDistribucion': notaDistribucion,
        'fechaGeneracion': fechaGeneracion.toIso8601String(),
      };
}
