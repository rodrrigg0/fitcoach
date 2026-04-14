import 'dart:math';

class SerieLog {
  final int numero;
  final double peso;
  final int repeticiones;

  const SerieLog({
    required this.numero,
    required this.peso,
    required this.repeticiones,
  });

  factory SerieLog.fromJson(Map<String, dynamic> json) => SerieLog(
        numero: (json['numero'] as num?)?.toInt() ?? 0,
        peso: (json['peso'] as num?)?.toDouble() ?? 0,
        repeticiones: (json['repeticiones'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'numero': numero,
        'peso': peso,
        'repeticiones': repeticiones,
      };

  SerieLog copyWith({int? numero, double? peso, int? repeticiones}) =>
      SerieLog(
        numero: numero ?? this.numero,
        peso: peso ?? this.peso,
        repeticiones: repeticiones ?? this.repeticiones,
      );
}

class ExerciseLog {
  final String id;
  final String ejercicioNombre;
  final String diaEntrenamiento;
  final DateTime fecha;
  final List<SerieLog> series;
  final String notas;

  const ExerciseLog({
    required this.id,
    required this.ejercicioNombre,
    required this.diaEntrenamiento,
    required this.fecha,
    required this.series,
    required this.notas,
  });

  double get pesoMaximo =>
      series.isEmpty ? 0 : series.map((s) => s.peso).reduce(max);

  double get volumenTotal =>
      series.fold(0, (sum, s) => sum + (s.peso * s.repeticiones));

  String get resumen => series
      .map((s) => '${s.numero}×${s.repeticiones} ${_formatPeso(s.peso)}kg')
      .join(' · ');

  String _formatPeso(double p) =>
      p == p.truncateToDouble() ? p.toInt().toString() : p.toStringAsFixed(1);

  factory ExerciseLog.fromJson(Map<String, dynamic> json) => ExerciseLog(
        id: json['id'] as String? ?? '',
        ejercicioNombre: json['ejercicioNombre'] as String? ?? '',
        diaEntrenamiento: json['diaEntrenamiento'] as String? ?? '',
        fecha: json['fecha'] != null
            ? DateTime.tryParse(json['fecha'] as String) ?? DateTime.now()
            : DateTime.now(),
        series: (json['series'] as List<dynamic>?)
                ?.map((e) => SerieLog.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        notas: json['notas'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ejercicioNombre': ejercicioNombre,
        'diaEntrenamiento': diaEntrenamiento,
        'fecha': fecha.toIso8601String(),
        'series': series.map((s) => s.toJson()).toList(),
        'notas': notas,
      };

  ExerciseLog copyWith({
    String? id,
    String? ejercicioNombre,
    String? diaEntrenamiento,
    DateTime? fecha,
    List<SerieLog>? series,
    String? notas,
  }) =>
      ExerciseLog(
        id: id ?? this.id,
        ejercicioNombre: ejercicioNombre ?? this.ejercicioNombre,
        diaEntrenamiento: diaEntrenamiento ?? this.diaEntrenamiento,
        fecha: fecha ?? this.fecha,
        series: series ?? this.series,
        notas: notas ?? this.notas,
      );
}

class WorkoutLog {
  final String id;
  final DateTime fecha;
  final String diaSemana;
  final String tituloEntrenamiento;
  final List<ExerciseLog> ejercicios;
  final bool completado;
  final String notas;

  const WorkoutLog({
    required this.id,
    required this.fecha,
    required this.diaSemana,
    required this.tituloEntrenamiento,
    required this.ejercicios,
    required this.completado,
    required this.notas,
  });

  double get volumenTotal =>
      ejercicios.fold(0.0, (sum, e) => sum + e.volumenTotal);

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: json['id'] as String? ?? '',
        fecha: json['fecha'] != null
            ? DateTime.tryParse(json['fecha'] as String) ?? DateTime.now()
            : DateTime.now(),
        diaSemana: json['diaSemana'] as String? ?? '',
        tituloEntrenamiento: json['tituloEntrenamiento'] as String? ?? '',
        ejercicios: (json['ejercicios'] as List<dynamic>?)
                ?.map((e) =>
                    ExerciseLog.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        completado: json['completado'] as bool? ?? false,
        notas: json['notas'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha': fecha.toIso8601String(),
        'diaSemana': diaSemana,
        'tituloEntrenamiento': tituloEntrenamiento,
        'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
        'completado': completado,
        'notas': notas,
      };

  WorkoutLog copyWith({
    String? id,
    DateTime? fecha,
    String? diaSemana,
    String? tituloEntrenamiento,
    List<ExerciseLog>? ejercicios,
    bool? completado,
    String? notas,
  }) =>
      WorkoutLog(
        id: id ?? this.id,
        fecha: fecha ?? this.fecha,
        diaSemana: diaSemana ?? this.diaSemana,
        tituloEntrenamiento:
            tituloEntrenamiento ?? this.tituloEntrenamiento,
        ejercicios: ejercicios ?? this.ejercicios,
        completado: completado ?? this.completado,
        notas: notas ?? this.notas,
      );
}
