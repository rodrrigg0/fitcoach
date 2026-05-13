import 'package:flutter/foundation.dart' show debugPrint;

int _parseIntSafe(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  return int.tryParse(v.toString()) ?? fallback;
}

double _parseDoubleSafe(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  return double.tryParse(v.toString()) ?? fallback;
}

class Meal {
  final String tipo;
  final String nombre;
  final int calorias;
  final double proteinas;
  final double carbohidratos;
  final double grasas;
  final String hora;
  final List<String> ingredientes;
  final String preparacion;
  final String timing;
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
    this.timing = 'Normal',
    this.completada = false,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final carbVal = json['carbohidratos'] ?? json['carbos'];
    final prepVal = json['preparacion'] ?? json['receta'];
    return Meal(
      tipo: json['tipo']?.toString() ?? 'snack',
      nombre: json['nombre']?.toString() ?? '',
      calorias: _parseIntSafe(json['calorias']),
      proteinas: _parseDoubleSafe(json['proteinas']),
      carbohidratos: _parseDoubleSafe(carbVal),
      grasas: _parseDoubleSafe(json['grasas']),
      hora: json['hora']?.toString() ?? '',
      ingredientes: (json['ingredientes'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .toList() ??
          [],
      preparacion: prepVal?.toString() ?? '',
      timing: json['timing']?.toString() ?? 'Normal',
      completada: json['completada'] == true,
    );
  }

  Meal copyWith({
    String? tipo,
    String? nombre,
    int? calorias,
    double? proteinas,
    double? carbohidratos,
    double? grasas,
    String? hora,
    List<String>? ingredientes,
    String? preparacion,
    String? timing,
    bool? completada,
  }) =>
      Meal(
        tipo: tipo ?? this.tipo,
        nombre: nombre ?? this.nombre,
        calorias: calorias ?? this.calorias,
        proteinas: proteinas ?? this.proteinas,
        carbohidratos: carbohidratos ?? this.carbohidratos,
        grasas: grasas ?? this.grasas,
        hora: hora ?? this.hora,
        ingredientes: ingredientes ?? this.ingredientes,
        preparacion: preparacion ?? this.preparacion,
        timing: timing ?? this.timing,
        completada: completada ?? this.completada,
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
        'timing': timing,
        'completada': completada,
      };
}

class DayMeals {
  final String diaSemana;
  final bool esDiaEntreno;
  final int caloriasDelDia;
  final int proteinasDelDia;
  final int carbosDelDia;
  final int grasasDelDia;
  final List<Meal> comidas;

  const DayMeals({
    required this.diaSemana,
    this.esDiaEntreno = false,
    required this.caloriasDelDia,
    this.proteinasDelDia = 0,
    this.carbosDelDia = 0,
    this.grasasDelDia = 0,
    required this.comidas,
  });

  factory DayMeals.fromJson(Map<String, dynamic> json) {
    final diaSemana =
        (json['diaSemana'] ?? json['dia'])?.toString() ?? '';

    final comidasJson = json['comidas'];
    final comidas = comidasJson is List
        ? [for (final m in comidasJson) Meal.fromJson(m as Map<String, dynamic>)]
        : <Meal>[];

    return DayMeals(
      diaSemana: diaSemana,
      esDiaEntreno: json['esDiaEntreno'] == true,
      caloriasDelDia: _parseIntSafe(
          json['caloriasDelDia'] ?? comidas.fold(0, (s, m) => s + m.calorias)),
      proteinasDelDia: _parseIntSafe(json['proteinasDelDia']),
      carbosDelDia: _parseIntSafe(json['carbosDelDia']),
      grasasDelDia: _parseIntSafe(json['grasasDelDia']),
      comidas: comidas,
    );
  }

  Map<String, dynamic> toJson() => {
        'diaSemana': diaSemana,
        'esDiaEntreno': esDiaEntreno,
        'caloriasDelDia': caloriasDelDia,
        'proteinasDelDia': proteinasDelDia,
        'carbosDelDia': carbosDelDia,
        'grasasDelDia': grasasDelDia,
        'comidas': comidas.map((m) => m.toJson()).toList(),
      };
}

class MealPlan {
  final String id;
  final List<Meal> comidas;
  final List<DayMeals> dias;
  final int caloriasObjetivo;
  final double proteinasObjetivo;
  final double carbosObjetivo;
  final double grasasObjetivo;
  final String notaNutricional;
  final DateTime fechaGeneracion;

  const MealPlan({
    this.id = '',
    required this.comidas,
    this.dias = const [],
    required this.caloriasObjetivo,
    required this.proteinasObjetivo,
    required this.carbosObjetivo,
    required this.grasasObjetivo,
    this.notaNutricional = '',
    required this.fechaGeneracion,
  });

  int get caloriasConsumidas =>
      comidas.where((m) => m.completada).fold(0, (sum, m) => sum + m.calorias);

  double get proteinasConsumidas =>
      comidas.where((m) => m.completada).fold(0.0, (sum, m) => sum + m.proteinas);

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final protVal = json['proteinasObjetivo'] ?? json['proteinaObjetivo'];

    List<DayMeals> dias = [];
    List<Meal> comidas = [];

    // CASO 1: JSON nuevo con "dias" como lista de objetos con "comidas"
    if (json['dias'] != null && json['dias'] is List) {
      final diasList = json['dias'] as List;
      if (diasList.isNotEmpty &&
          diasList.first is Map &&
          (diasList.first as Map).containsKey('comidas')) {
        dias = diasList
            .map((d) => DayMeals.fromJson(d as Map<String, dynamic>))
            .toList();
        comidas = dias.expand((d) => d.comidas).toList();
      }
    }

    // CASO 2: JSON plano con "comidas" directamente
    if (dias.isEmpty) {
      comidas = (json['comidas'] as List<dynamic>?)
              ?.map((e) => Meal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    }

    debugPrint('=== MEALPLAN FROMJSON: ${dias.length} días, ${comidas.length} comidas ===');
    for (final dia in dias) {
      debugPrint('  ${dia.diaSemana}: ${dia.comidas.length} comidas (${dia.caloriasDelDia} kcal)');
    }

    return MealPlan(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      comidas: comidas,
      dias: dias,
      caloriasObjetivo: _parseIntSafe(json['caloriasObjetivo'], 2000),
      proteinasObjetivo: _parseDoubleSafe(protVal, 150.0),
      carbosObjetivo: _parseDoubleSafe(
          json['carbosObjetivo'] ?? json['carbohidratosObjetivo'], 200.0),
      grasasObjetivo: _parseDoubleSafe(json['grasasObjetivo'], 65.0),
      notaNutricional: json['notaNutricional']?.toString() ?? '',
      fechaGeneracion: json['fechaGeneracion'] != null
          ? DateTime.tryParse(json['fechaGeneracion'].toString()) ??
              DateTime.now()
          : DateTime.now(),
    );
  }

  MealPlan copyWith({
    String? id,
    List<Meal>? comidas,
    List<DayMeals>? dias,
    int? caloriasObjetivo,
    double? proteinasObjetivo,
    double? carbosObjetivo,
    double? grasasObjetivo,
    String? notaNutricional,
    DateTime? fechaGeneracion,
  }) =>
      MealPlan(
        id: id ?? this.id,
        comidas: comidas ?? this.comidas,
        dias: dias ?? this.dias,
        caloriasObjetivo: caloriasObjetivo ?? this.caloriasObjetivo,
        proteinasObjetivo: proteinasObjetivo ?? this.proteinasObjetivo,
        carbosObjetivo: carbosObjetivo ?? this.carbosObjetivo,
        grasasObjetivo: grasasObjetivo ?? this.grasasObjetivo,
        notaNutricional: notaNutricional ?? this.notaNutricional,
        fechaGeneracion: fechaGeneracion ?? this.fechaGeneracion,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'comidas': comidas.map((m) => m.toJson()).toList(),
        'dias': dias.map((d) => d.toJson()).toList(),
        'caloriasObjetivo': caloriasObjetivo,
        'proteinasObjetivo': proteinasObjetivo,
        'carbosObjetivo': carbosObjetivo,
        'grasasObjetivo': grasasObjetivo,
        'notaNutricional': notaNutricional,
        'fechaGeneracion': fechaGeneracion.toIso8601String(),
      };
}
