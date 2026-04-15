class WeightLog {
  final DateTime fecha;
  final double peso;
  final String notas;

  const WeightLog({
    required this.fecha,
    required this.peso,
    this.notas = '',
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) => WeightLog(
        fecha: json['fecha'] != null
            ? DateTime.tryParse(json['fecha'] as String) ?? DateTime.now()
            : DateTime.now(),
        peso: (json['peso'] as num?)?.toDouble() ?? 0,
        notas: json['notas'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'fecha': fecha.toIso8601String(),
        'peso': peso,
        'notas': notas,
      };
}
