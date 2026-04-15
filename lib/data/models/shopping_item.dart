class ShoppingItem {
  final String nombre;
  final String cantidad;
  final String categoria;
  final bool comprado;

  const ShoppingItem({
    required this.nombre,
    required this.cantidad,
    required this.categoria,
    this.comprado = false,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        nombre: json['nombre'] as String? ?? '',
        cantidad: json['cantidad'] as String? ?? '',
        categoria: json['categoria'] as String? ?? 'Otros',
        comprado: json['comprado'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'cantidad': cantidad,
        'categoria': categoria,
        'comprado': comprado,
      };

  ShoppingItem copyWith({
    String? nombre,
    String? cantidad,
    String? categoria,
    bool? comprado,
  }) =>
      ShoppingItem(
        nombre: nombre ?? this.nombre,
        cantidad: cantidad ?? this.cantidad,
        categoria: categoria ?? this.categoria,
        comprado: comprado ?? this.comprado,
      );
}
