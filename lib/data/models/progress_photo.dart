class ProgressPhoto {
  final String id;
  final DateTime fecha;
  final String url;
  final String? notas;
  final double? peso;

  const ProgressPhoto({
    required this.id,
    required this.fecha,
    required this.url,
    this.notas,
    this.peso,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha': fecha.toIso8601String(),
        'url': url,
        if (notas != null) 'notas': notas,
        if (peso != null) 'peso': peso,
      };

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) => ProgressPhoto(
        id: json['id'] as String,
        fecha: DateTime.parse(json['fecha'] as String),
        url: json['url'] as String,
        notas: json['notas'] as String?,
        peso: (json['peso'] as num?)?.toDouble(),
      );
}
