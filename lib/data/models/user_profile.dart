class UserProfile {
  final String id;
  final String nombre;
  final int edad;
  final String sexo;
  final double peso;
  final double altura;
  final String objetivo;
  final String nivelActividad;
  final List<String> deportes;
  final int diasEntrenamiento;
  final int minutosSesion;
  final String lugarEntrenamiento;
  final String lesiones;
  final String tipoDieta;
  final List<String> alergias;
  final int presupuestoSemanal;
  final int horasSueno;
  final List<String> suplementosActuales;
  final bool onboardingCompletado;
  final DateTime fechaRegistro;

  const UserProfile({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.sexo,
    required this.peso,
    required this.altura,
    required this.objetivo,
    required this.nivelActividad,
    required this.deportes,
    required this.diasEntrenamiento,
    required this.minutosSesion,
    required this.lugarEntrenamiento,
    required this.lesiones,
    required this.tipoDieta,
    required this.alergias,
    required this.presupuestoSemanal,
    required this.horasSueno,
    required this.suplementosActuales,
    required this.onboardingCompletado,
    required this.fechaRegistro,
  });

  factory UserProfile.vacio() => UserProfile(
        id: '',
        nombre: '',
        edad: 0,
        sexo: '',
        peso: 0.0,
        altura: 0.0,
        objetivo: '',
        nivelActividad: '',
        deportes: const [],
        diasEntrenamiento: 0,
        minutosSesion: 0,
        lugarEntrenamiento: '',
        lesiones: '',
        tipoDieta: '',
        alergias: const [],
        presupuestoSemanal: 0,
        horasSueno: 0,
        suplementosActuales: const [],
        onboardingCompletado: false,
        fechaRegistro: DateTime.now(),
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String? ?? '',
        nombre: json['nombre'] as String? ?? '',
        edad: (json['edad'] as num?)?.toInt() ?? 0,
        sexo: json['sexo'] as String? ?? '',
        peso: (json['peso'] as num?)?.toDouble() ?? 0.0,
        altura: (json['altura'] as num?)?.toDouble() ?? 0.0,
        objetivo: json['objetivo'] as String? ?? '',
        nivelActividad: json['nivelActividad'] as String? ?? '',
        deportes: (json['deportes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        diasEntrenamiento:
            (json['diasEntrenamiento'] as num?)?.toInt() ?? 0,
        minutosSesion: (json['minutosSesion'] as num?)?.toInt() ?? 0,
        lugarEntrenamiento: json['lugarEntrenamiento'] as String? ?? '',
        lesiones: json['lesiones'] as String? ?? '',
        tipoDieta: json['tipoDieta'] as String? ?? '',
        alergias: (json['alergias'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        presupuestoSemanal:
            (json['presupuestoSemanal'] as num?)?.toInt() ?? 0,
        horasSueno: (json['horasSueno'] as num?)?.toInt() ?? 0,
        suplementosActuales:
            (json['suplementosActuales'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
        onboardingCompletado:
            json['onboardingCompletado'] as bool? ?? false,
        fechaRegistro: json['fechaRegistro'] != null
            ? DateTime.parse(json['fechaRegistro'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'edad': edad,
        'sexo': sexo,
        'peso': peso,
        'altura': altura,
        'objetivo': objetivo,
        'nivelActividad': nivelActividad,
        'deportes': deportes,
        'diasEntrenamiento': diasEntrenamiento,
        'minutosSesion': minutosSesion,
        'lugarEntrenamiento': lugarEntrenamiento,
        'lesiones': lesiones,
        'tipoDieta': tipoDieta,
        'alergias': alergias,
        'presupuestoSemanal': presupuestoSemanal,
        'horasSueno': horasSueno,
        'suplementosActuales': suplementosActuales,
        'onboardingCompletado': onboardingCompletado,
        'fechaRegistro': fechaRegistro.toIso8601String(),
      };

  UserProfile copyWith({
    String? id,
    String? nombre,
    int? edad,
    String? sexo,
    double? peso,
    double? altura,
    String? objetivo,
    String? nivelActividad,
    List<String>? deportes,
    int? diasEntrenamiento,
    int? minutosSesion,
    String? lugarEntrenamiento,
    String? lesiones,
    String? tipoDieta,
    List<String>? alergias,
    int? presupuestoSemanal,
    int? horasSueno,
    List<String>? suplementosActuales,
    bool? onboardingCompletado,
    DateTime? fechaRegistro,
  }) =>
      UserProfile(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        edad: edad ?? this.edad,
        sexo: sexo ?? this.sexo,
        peso: peso ?? this.peso,
        altura: altura ?? this.altura,
        objetivo: objetivo ?? this.objetivo,
        nivelActividad: nivelActividad ?? this.nivelActividad,
        deportes: deportes ?? this.deportes,
        diasEntrenamiento: diasEntrenamiento ?? this.diasEntrenamiento,
        minutosSesion: minutosSesion ?? this.minutosSesion,
        lugarEntrenamiento:
            lugarEntrenamiento ?? this.lugarEntrenamiento,
        lesiones: lesiones ?? this.lesiones,
        tipoDieta: tipoDieta ?? this.tipoDieta,
        alergias: alergias ?? this.alergias,
        presupuestoSemanal:
            presupuestoSemanal ?? this.presupuestoSemanal,
        horasSueno: horasSueno ?? this.horasSueno,
        suplementosActuales:
            suplementosActuales ?? this.suplementosActuales,
        onboardingCompletado:
            onboardingCompletado ?? this.onboardingCompletado,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      );
}
