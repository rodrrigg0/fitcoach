import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/data/models/chat_message.dart';
import 'package:fitcoach/data/services/chat_provider.dart';
import 'package:fitcoach/data/services/home_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final Set<String> _animatedIds = {};
  bool _inputHasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _inputHasText) {
        setState(() => _inputHasText = hasText);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ChatProvider>().inicializar();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _shouldAnimate(ChatMessage m) {
    if (_animatedIds.contains(m.id)) return false;
    _animatedIds.add(m.id);
    return true;
  }

  Future<void> _enviar([String? override]) async {
    final texto = override ?? _controller.text.trim();
    if (texto.isEmpty) return;
    if (override == null) _controller.clear();
    await context.read<ChatProvider>().enviarMensaje(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        if (chat.planActualizado) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<HomeProvider>().cargarDatos();
              chat.resetPlanActualizado();
            }
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: chat.tieneHistorial
                      ? _buildMessageList(chat)
                      : _buildWelcomeState(chat),
                ),
                _buildInputBar(chat),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Estado vacío ─────────────────────────────────────────

  Widget _buildWelcomeState(ChatProvider chat) {
    final nombre = chat.perfil?.nombre ?? '';
    final deporte = chat.perfil?.deportes.firstOrNull ?? 'tu deporte';
    final sugerencias = _getSugerencias(chat, deporte);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Center(
                child: Text(
                  'FC',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¿En qué puedo',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              'ayudarte hoy?',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              nombre.isNotEmpty
                  ? 'Hola $nombre, soy tu entrenador personal'
                  : 'Hola, soy tu entrenador personal',
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: sugerencias.map(_buildSugerencia).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<_Sugerencia> _getSugerencias(ChatProvider chat, String deporte) {
    final list = <_Sugerencia>[];
    if (chat.planEntrenamiento != null) {
      list.add(const _Sugerencia(
        'Modifica mi entrenamiento de hoy',
        'Ajusta la sesión según cómo me encuentro',
      ));
      list.add(const _Sugerencia(
        '¿Qué suplementos debo tomar?',
        'Recomendación personalizada para mi objetivo',
      ));
    }
    if (chat.planNutricion != null) {
      list.add(const _Sugerencia(
        'Cambia mi cena de hoy',
        'Sugiere una alternativa más económica',
      ));
    }
    list.add(_Sugerencia(
      '¿Cómo mejoro mi rendimiento en $deporte?',
      'Consejos específicos para tu disciplina',
    ));
    return list;
  }

  Widget _buildSugerencia(_Sugerencia s) {
    return GestureDetector(
      onTap: () => _enviar(s.titulo),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.titulo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.descripcion,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFF444444), size: 16),
          ],
        ),
      ),
    );
  }

  // ─── Lista de mensajes ────────────────────────────────────

  Widget _buildMessageList(ChatProvider chat) {
    final msgs = chat.mensajes;
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: msgs.length,
      itemBuilder: (ctx, i) {
        final msg = msgs[msgs.length - 1 - i];
        if (msg.estaCargando) return const TypingIndicator();
        final animate = _shouldAnimate(msg);
        return TweenAnimationBuilder<double>(
          key: ValueKey('bubble_${msg.id}'),
          tween: Tween<double>(
              begin: animate ? 0.0 : 1.0, end: 1.0),
          duration: animate
              ? const Duration(milliseconds: 350)
              : Duration.zero,
          curve: Curves.easeOut,
          builder: (ctx, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20.0 * (1.0 - value)),
                child: child,
              ),
            );
          },
          child: _BubbleWidget(mensaje: msg),
        );
      },
    );
  }

  // ─── Campo de entrada ─────────────────────────────────────

  Widget _buildInputBar(ChatProvider chat) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
            top: BorderSide(color: Color(0xFF1A1A1A), width: 0.5)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu pregunta...',
                  hintStyle:
                      TextStyle(color: Color(0xFF444444), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(
                  milliseconds: disableAnimations ? 0 : 200),
              child: (_inputHasText && !chat.enviando)
                  ? GestureDetector(
                      key: const ValueKey('send'),
                      onTap: _enviar,
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          color: AppColors.background,
                          size: 18,
                        ),
                      ),
                    )
                  : const SizedBox(
                      key: ValueKey('empty'), width: 8),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sugerencia data class ────────────────────────────────

class _Sugerencia {
  final String titulo;
  final String descripcion;
  const _Sugerencia(this.titulo, this.descripcion);
}

// ─── Typing indicator ─────────────────────────────────────

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _maxHeights = [18.0, 26.0, 22.0, 28.0, 16.0];
  int _textIdx = 0;

  static const _texts = [
    'Analizando...',
    'Procesando...',
    'Preparando respuesta...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      setState(() => _textIdx = (_textIdx + 1) % _texts.length);
      return mounted;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 60),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(
              color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(5, (i) {
                if (disableAnimations) {
                  return Container(
                    width: 3,
                    height: 16,
                    margin: EdgeInsets.only(left: i > 0 ? 3 : 0),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }
                final anim = Tween<double>(
                        begin: 4, end: _maxHeights[i])
                    .animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      (i * 0.15).clamp(0.0, 1.0),
                      (i * 0.15 + 0.55).clamp(0.0, 1.0),
                      curve: Curves.easeInOut,
                    ),
                  ),
                );
                return AnimatedBuilder(
                  animation: anim,
                  builder: (ctx, _) => Container(
                    width: 3,
                    height: anim.value,
                    margin:
                        EdgeInsets.only(left: i > 0 ? 3 : 0),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _texts[_textIdx],
                key: ValueKey(_textIdx),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Burbuja de mensaje ───────────────────────────────────

class _BubbleWidget extends StatelessWidget {
  final ChatMessage mensaje;
  const _BubbleWidget({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    if (mensaje.esMensajeSistema) {
      return Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x10C8F135),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0x40C8F135), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppColors.primary, size: 14),
              const SizedBox(width: 6),
              Text(
                mensaje.contenido,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (mensaje.esUsuario) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 60),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            mensaje.contenido,
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    // Mensaje del entrenador (IA)
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 60),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(
              color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _renderizarMensaje(mensaje.contenido),
            const SizedBox(height: 6),
            Text(
              _formatTime(mensaje.timestamp),
              style: const TextStyle(
                color: Color(0xFF444444),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderizarMensaje(String texto) {
    final lines = texto.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }
      final stripped = line.trimLeft();

      if (stripped.startsWith('- ') || stripped.startsWith('• ')) {
        final content = stripped.substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(content,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.6)),
              ),
            ],
          ),
        ));
        continue;
      }

      final numMatch =
          RegExp(r'^(\d+)\.\s(.*)').firstMatch(stripped);
      if (numMatch != null) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${numMatch.group(1)}.',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(numMatch.group(2) ?? '',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.6)),
              ),
            ],
          ),
        ));
        continue;
      }

      if (stripped.startsWith('**') &&
          stripped.endsWith('**') &&
          stripped.length > 4) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            stripped.substring(2, stripped.length - 2),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ));
        continue;
      }

      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text(
          line,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
