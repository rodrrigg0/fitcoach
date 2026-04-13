class Meal {
  final String tipo; // 'desayuno' | 'almuerzo' | 'cena' | 'snack'
  final String nombre;
  final int calorias;
  final double proteinas;
  final double carbohidratos;
  final double grasas;
  final String hora;
  final List<String> ingredientes;
  final String preparacion;
  bool completada;

  Meal({
    required this.tipo,
    required this.nombre,
    required this.calorias,
    required this.proteinas,
    required this.carbohidratos,
    required this.grasas,
    required this.hora,
    required this.ingredientes,
    required this.preparacion,
    this.completada = false,
  });

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        tipo: json['tipo'] as String? ?? 'snack',
        nombre: json['nombre'] as String? ?? '',
        calorias: (json['calorias'] as num?)?.toInt() ?? 0,
        proteinas: (json['proteinas'] as num?)?.toDouble() ?? 0,
        carbohidratos: (json['carbohidratos'] as num?)?.toDouble() ?? 0,
        grasas: (json['grasas'] as num?)?.toDouble() ?? 0,
        hora: json['hora'] as String? ?? '',
        ingredientes: (json['ingredientes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        preparacion: json['preparacion'] as String? ?? '',
        completada: json['completada'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        'nombre': nombre,
        'calorias': calorias,
        'proteinas': proteinas,
        'carbohidratos': carbohidratos,
        'grasas': grasas,
        'hora': hora,
        'ingredientes': ingredientes,
        'preparacion': preparacion,
        'completada': completada,
      };
}

class MealPlan {
  final List<Meal> comidas;
  final int caloriasObjetivo;
  final double proteinasObjetivo;
  final double carbosObjetivo;
  final double grasasObjetivo;
  final DateTime fechaGeneracion;

  const MealPlan({
    required this.comidas,
    required this.caloriasObjetivo,
    required this.proteinasObjetivo,
    required this.carbosObjetivo,
    required this.grasasObjetivo,
    required this.fechaGeneracion,
  });

  int get caloriasConsumidas =>
      comidas.where((m) => m.completada).fold(0, (sum, m) => sum + m.calorias);

  double get proteinasConsumidas =>
      comidas.where((m) => m.completada).fold(0.0, (sum, m) => sum + m.proteinas);

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
        comidas: (json['comidas'] as List<dynamic>?)
                ?.map((e) => Meal.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        caloriasObjetivo: (json['caloriasObjetivo'] as num?)?.toInt() ?? 2000,
        proteinasObjetivo: (json['proteinasObjetivo'] as num?)?.toDouble() ?? 150,
        carbosObjetivo: (json['carbosObjetivo'] as num?)?.toDouble() ?? 200,
        grasasObjetivo: (json['grasasObjetivo'] as num?)?.toDouble() ?? 65,
        fechaGeneracion: json['fechaGeneracion'] != null
            ? DateTime.tryParse(json['fechaGeneracion'] as String) ??
                DateTime.now()
            : DateTime.now(),
      );

  MealPlan copyWith({
    List<Meal>? comidas,
    int? caloriasObjetivo,
    double? proteinasObjetivo,
    double? carbosObjetivo,
    double? grasasObjetivo,
    DateTime? fechaGeneracion,
  }) =>
      MealPlan(
        comidas: comidas ?? this.comidas,
        caloriasObjetivo: caloriasObjetivo ?? this.caloriasObjetivo,
        proteinasObjetivo: proteinasObjetivo ?? this.proteinasObjetivo,
        carbosObjetivo: carbosObjetivo ?? this.carbosObjetivo,
        grasasObjetivo: grasasObjetivo ?? this.grasasObjetivo,
        fechaGeneracion: fechaGeneracion ?? this.fechaGeneracion,
      );

  Map<String, dynamic> toJson() => {
        'comidas': comidas.map((m) => m.toJson()).toList(),
        'caloriasObjetivo': caloriasObjetivo,
        'proteinasObjetivo': proteinasObjetivo,
        'carbosObjetivo': carbosObjetivo,
        'grasasObjetivo': grasasObjetivo,
        'fechaGeneracion': fechaGeneracion.toIso8601String(),
      };
}
