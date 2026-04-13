class Exercise {
  final String nombre;
  final String? series;
  final String? duracion;
  final String? distancia;

  const Exercise({
    required this.nombre,
    this.series,
    this.duracion,
    this.distancia,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        nombre: json['nombre'] as String? ?? '',
        series: json['series'] as String?,
        duracion: json['duracion'] as String?,
        distancia: json['distancia'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        if (series != null) 'series': series,
        if (duracion != null) 'duracion': duracion,
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
        tipo: json['tipo'] as String? ?? 'descanso',
        titulo: json['titulo'] as String? ?? 'Descanso',
        descripcion: json['descripcion'] as String? ?? '',
        duracion: (json['duracion'] as num?)?.toInt() ?? 0,
        lugar: json['lugar'] as String? ?? '',
        ejercicios: (json['ejercicios'] as List<dynamic>?)
                ?.map((e) =>
                    Exercise.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        porQueHoy: json['porQueHoy'] as String? ?? '',
        objetivos: (json['objetivos'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        consejo: json['consejo'] as String? ?? '',
        caracteristicas: (json['caracteristicas'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        completado: json['completado'] as bool? ?? false,
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
      notaDistribucion: json['notaDistribucion'] as String? ?? '',
      fechaGeneracion: json['fechaGeneracion'] != null
          ? DateTime.tryParse(json['fechaGeneracion'] as String) ??
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
