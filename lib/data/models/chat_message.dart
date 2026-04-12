import 'package:uuid/uuid.dart';

class ChatMessage {
  final String id;
  final String contenido;
  final bool esUsuario;
  final DateTime timestamp;
  final bool estaCargando;

  const ChatMessage({
    required this.id,
    required this.contenido,
    required this.esUsuario,
    required this.timestamp,
    this.estaCargando = false,
  });

  factory ChatMessage.deUsuario(String contenido) => ChatMessage(
        id: const Uuid().v4(),
        contenido: contenido,
        esUsuario: true,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.deIA(String contenido) => ChatMessage(
        id: const Uuid().v4(),
        contenido: contenido,
        esUsuario: false,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.cargando() => ChatMessage(
        id: const Uuid().v4(),
        contenido: '',
        esUsuario: false,
        timestamp: DateTime.now(),
        estaCargando: true,
      );

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        contenido: json['contenido'] as String,
        esUsuario: json['esUsuario'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
        estaCargando: json['estaCargando'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'contenido': contenido,
        'esUsuario': esUsuario,
        'timestamp': timestamp.toIso8601String(),
        'estaCargando': estaCargando,
      };

  ChatMessage copyWith({
    String? id,
    String? contenido,
    bool? esUsuario,
    DateTime? timestamp,
    bool? estaCargando,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        contenido: contenido ?? this.contenido,
        esUsuario: esUsuario ?? this.esUsuario,
        timestamp: timestamp ?? this.timestamp,
        estaCargando: estaCargando ?? this.estaCargando,
      );
}
