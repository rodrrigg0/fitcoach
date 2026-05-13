class DailyCheckin {
  final String id;
  final String uid;
  final DateTime fecha;
  final String diaSemana;
  final bool esDiaEntreno;

  final int? nivelEnergia;
  final int? nivelRendimiento;
  final int? nivelDolor;
  final bool? completoTodosEjercicios;
  final String? ejerciciosModificados;
  final String? notasEntreno;

  final bool? completoDesayuno;
  final bool? completoAlmuerzo;
  final bool? completoCena;
  final bool? completoSnacks;
  final int? vasosDe250ml;

  final double? horasSueno;
  final int? calidadSueno;
  final bool? descansoCumplido;

  final int? nivelRecuperacion;
  final String? dudas;

  final String? preguntaEntrenador;
  final String? respuestaEntrenador;
  final DateTime? fechaRespuesta;

  final bool esInformeSemanal;
  final String? informeSemanal;

  const DailyCheckin({
    required this.id,
    required this.uid,
    required this.fecha,
    required this.diaSemana,
    required this.esDiaEntreno,
    this.nivelEnergia,
    this.nivelRendimiento,
    this.nivelDolor,
    this.completoTodosEjercicios,
    this.ejerciciosModificados,
    this.notasEntreno,
    this.completoDesayuno,
    this.completoAlmuerzo,
    this.completoCena,
    this.completoSnacks,
    this.vasosDe250ml,
    this.horasSueno,
    this.calidadSueno,
    this.descansoCumplido,
    this.nivelRecuperacion,
    this.dudas,
    this.preguntaEntrenador,
    this.respuestaEntrenador,
    this.fechaRespuesta,
    this.esInformeSemanal = false,
    this.informeSemanal,
  });

  factory DailyCheckin.fromJson(Map<String, dynamic> json) {
    return DailyCheckin(
      id: json['id'] as String,
      uid: json['uid'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      diaSemana: json['diaSemana'] as String,
      esDiaEntreno: json['esDiaEntreno'] as bool? ?? false,
      nivelEnergia: json['nivelEnergia'] as int?,
      nivelRendimiento: json['nivelRendimiento'] as int?,
      nivelDolor: json['nivelDolor'] as int?,
      completoTodosEjercicios: json['completoTodosEjercicios'] as bool?,
      ejerciciosModificados: json['ejerciciosModificados'] as String?,
      notasEntreno: json['notasEntreno'] as String?,
      completoDesayuno: json['completoDesayuno'] as bool?,
      completoAlmuerzo: json['completoAlmuerzo'] as bool?,
      completoCena: json['completoCena'] as bool?,
      completoSnacks: json['completoSnacks'] as bool?,
      vasosDe250ml: json['vasosDe250ml'] as int?,
      horasSueno: (json['horasSueno'] as num?)?.toDouble(),
      calidadSueno: json['calidadSueno'] as int?,
      descansoCumplido: json['descansoCumplido'] as bool?,
      nivelRecuperacion: json['nivelRecuperacion'] as int?,
      dudas: json['dudas'] as String?,
      preguntaEntrenador: json['preguntaEntrenador'] as String?,
      respuestaEntrenador: json['respuestaEntrenador'] as String?,
      fechaRespuesta: json['fechaRespuesta'] != null
          ? DateTime.parse(json['fechaRespuesta'] as String)
          : null,
      esInformeSemanal: json['esInformeSemanal'] as bool? ?? false,
      informeSemanal: json['informeSemanal'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'fecha': fecha.toIso8601String(),
      'diaSemana': diaSemana,
      'esDiaEntreno': esDiaEntreno,
      if (nivelEnergia != null) 'nivelEnergia': nivelEnergia,
      if (nivelRendimiento != null) 'nivelRendimiento': nivelRendimiento,
      if (nivelDolor != null) 'nivelDolor': nivelDolor,
      if (completoTodosEjercicios != null)
        'completoTodosEjercicios': completoTodosEjercicios,
      if (ejerciciosModificados != null)
        'ejerciciosModificados': ejerciciosModificados,
      if (notasEntreno != null) 'notasEntreno': notasEntreno,
      if (completoDesayuno != null) 'completoDesayuno': completoDesayuno,
      if (completoAlmuerzo != null) 'completoAlmuerzo': completoAlmuerzo,
      if (completoCena != null) 'completoCena': completoCena,
      if (completoSnacks != null) 'completoSnacks': completoSnacks,
      if (vasosDe250ml != null) 'vasosDe250ml': vasosDe250ml,
      if (horasSueno != null) 'horasSueno': horasSueno,
      if (calidadSueno != null) 'calidadSueno': calidadSueno,
      if (descansoCumplido != null) 'descansoCumplido': descansoCumplido,
      if (nivelRecuperacion != null) 'nivelRecuperacion': nivelRecuperacion,
      if (dudas != null) 'dudas': dudas,
      if (preguntaEntrenador != null) 'preguntaEntrenador': preguntaEntrenador,
      if (respuestaEntrenador != null)
        'respuestaEntrenador': respuestaEntrenador,
      if (fechaRespuesta != null)
        'fechaRespuesta': fechaRespuesta!.toIso8601String(),
      'esInformeSemanal': esInformeSemanal,
      if (informeSemanal != null) 'informeSemanal': informeSemanal,
    };
  }

  DailyCheckin copyWith({
    String? id,
    String? uid,
    DateTime? fecha,
    String? diaSemana,
    bool? esDiaEntreno,
    int? nivelEnergia,
    int? nivelRendimiento,
    int? nivelDolor,
    bool? completoTodosEjercicios,
    String? ejerciciosModificados,
    String? notasEntreno,
    bool? completoDesayuno,
    bool? completoAlmuerzo,
    bool? completoCena,
    bool? completoSnacks,
    int? vasosDe250ml,
    double? horasSueno,
    int? calidadSueno,
    bool? descansoCumplido,
    int? nivelRecuperacion,
    String? dudas,
    String? preguntaEntrenador,
    String? respuestaEntrenador,
    DateTime? fechaRespuesta,
    bool? esInformeSemanal,
    String? informeSemanal,
  }) {
    return DailyCheckin(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      fecha: fecha ?? this.fecha,
      diaSemana: diaSemana ?? this.diaSemana,
      esDiaEntreno: esDiaEntreno ?? this.esDiaEntreno,
      nivelEnergia: nivelEnergia ?? this.nivelEnergia,
      nivelRendimiento: nivelRendimiento ?? this.nivelRendimiento,
      nivelDolor: nivelDolor ?? this.nivelDolor,
      completoTodosEjercicios:
          completoTodosEjercicios ?? this.completoTodosEjercicios,
      ejerciciosModificados:
          ejerciciosModificados ?? this.ejerciciosModificados,
      notasEntreno: notasEntreno ?? this.notasEntreno,
      completoDesayuno: completoDesayuno ?? this.completoDesayuno,
      completoAlmuerzo: completoAlmuerzo ?? this.completoAlmuerzo,
      completoCena: completoCena ?? this.completoCena,
      completoSnacks: completoSnacks ?? this.completoSnacks,
      vasosDe250ml: vasosDe250ml ?? this.vasosDe250ml,
      horasSueno: horasSueno ?? this.horasSueno,
      calidadSueno: calidadSueno ?? this.calidadSueno,
      descansoCumplido: descansoCumplido ?? this.descansoCumplido,
      nivelRecuperacion: nivelRecuperacion ?? this.nivelRecuperacion,
      dudas: dudas ?? this.dudas,
      preguntaEntrenador: preguntaEntrenador ?? this.preguntaEntrenador,
      respuestaEntrenador: respuestaEntrenador ?? this.respuestaEntrenador,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
      esInformeSemanal: esInformeSemanal ?? this.esInformeSemanal,
      informeSemanal: informeSemanal ?? this.informeSemanal,
    );
  }
}

class WeeklySummary {
  final String id;
  final String uid;
  final DateTime semanaInicio;
  final DateTime semanaFin;
  final List<DailyCheckin> checkins;
  final double pesoInicioSemana;
  final double? pesoFinSemana;
  final int sesionesCompletadas;
  final int sesionesPlaneadas;
  final double porcentajeCumplimientoComidas;
  final double promedioSueno;
  final double promedioEnergia;
  final double promedioRendimiento;
  final String? informeIA;
  final DateTime fechaGeneracion;

  const WeeklySummary({
    required this.id,
    required this.uid,
    required this.semanaInicio,
    required this.semanaFin,
    required this.checkins,
    required this.pesoInicioSemana,
    this.pesoFinSemana,
    required this.sesionesCompletadas,
    required this.sesionesPlaneadas,
    required this.porcentajeCumplimientoComidas,
    required this.promedioSueno,
    required this.promedioEnergia,
    required this.promedioRendimiento,
    this.informeIA,
    required this.fechaGeneracion,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      id: json['id'] as String,
      uid: json['uid'] as String,
      semanaInicio: DateTime.parse(json['semanaInicio'] as String),
      semanaFin: DateTime.parse(json['semanaFin'] as String),
      checkins: (json['checkins'] as List<dynamic>? ?? [])
          .map((e) => DailyCheckin.fromJson(e as Map<String, dynamic>))
          .toList(),
      pesoInicioSemana: (json['pesoInicioSemana'] as num).toDouble(),
      pesoFinSemana: (json['pesoFinSemana'] as num?)?.toDouble(),
      sesionesCompletadas: json['sesionesCompletadas'] as int,
      sesionesPlaneadas: json['sesionesPlaneadas'] as int,
      porcentajeCumplimientoComidas:
          (json['porcentajeCumplimientoComidas'] as num).toDouble(),
      promedioSueno: (json['promedioSueno'] as num).toDouble(),
      promedioEnergia: (json['promedioEnergia'] as num).toDouble(),
      promedioRendimiento: (json['promedioRendimiento'] as num).toDouble(),
      informeIA: json['informeIA'] as String?,
      fechaGeneracion: DateTime.parse(json['fechaGeneracion'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'semanaInicio': semanaInicio.toIso8601String(),
      'semanaFin': semanaFin.toIso8601String(),
      'checkins': checkins.map((c) => c.toJson()).toList(),
      'pesoInicioSemana': pesoInicioSemana,
      if (pesoFinSemana != null) 'pesoFinSemana': pesoFinSemana,
      'sesionesCompletadas': sesionesCompletadas,
      'sesionesPlaneadas': sesionesPlaneadas,
      'porcentajeCumplimientoComidas': porcentajeCumplimientoComidas,
      'promedioSueno': promedioSueno,
      'promedioEnergia': promedioEnergia,
      'promedioRendimiento': promedioRendimiento,
      if (informeIA != null) 'informeIA': informeIA,
      'fechaGeneracion': fechaGeneracion.toIso8601String(),
    };
  }
}
